//
//  EcomapFetcher.m
//  EcomapFetcher
//
//  Created by Vasilii Kotsiuba on 2/3/15.
//  Copyright (c) 2015 Vasyl Kotsiuba. All rights reserved.
//

#import "EcomapFetcher.h"
#import "EcomapPathDefine.h"
#import "EcomapURLFetcher.h"
#import "EcomapProblem.h"
#import "EcomapProblemDetails.h"
#import "EcomapLoggedUser.h"


@implementation EcomapFetcher

#pragma mark - Load all Problems
+(void)loadAllProblemsOnCompletion:(void (^)(NSArray *problems, NSError *error))completionHandler
{
    [self dataTaskWithRequest:[NSURLRequest requestWithURL:[EcomapURLFetcher URLforAllProblems]]
             sessionConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]
                completionHandler:^(NSData *JSON, NSError *error) {
                    NSMutableArray *problems = nil;
                    NSArray *problemsFromJSON = nil;
                    if (!error) {
                        //Extract received data
                        if (JSON != nil) {
                            //Parse JSON
                            problemsFromJSON = [EcomapFetcher parseJSONtoArray:JSON];
                            
                            //Fill problems array
                            if (problemsFromJSON) {
                                problems = [NSMutableArray array];
                                //Fill array with EcomapProblem
                                for (NSDictionary *problem in problemsFromJSON) {
                                    EcomapProblem *ecoProblem = [[EcomapProblem alloc] initWithProblem:problem];
                                    [problems addObject:ecoProblem];
                                }
                            }
                            
                        }
                    }
                    //set up completionHandler
                    completionHandler(problems, error);
                }];

    
}

#pragma mark - Load Problem with ID
+ (void)loadProblemDetailsWithID:(NSUInteger)problemID OnCompletion:(void (^)(EcomapProblemDetails *problemDetails, NSError *error))completionHandler
{
    [self dataTaskWithRequest:[NSURLRequest requestWithURL:[EcomapURLFetcher URLforProblemWithID:problemID]]
             sessionConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]
                completionHandler:^(NSData *JSON, NSError *error) {
                    NSDictionary *problem = nil;
                    EcomapProblemDetails *problemDetails = nil;
                    if (!error) {
                        //Extract received data
                        if (JSON != nil) {
                            //Check if we have a problem with such problemID.
                            //If there is no one, server give us back Dictionary with "error" key
                            //Parse JSON
                            NSDictionary *answerFromServer = [EcomapFetcher parseJSONtoDictionary:JSON];
                            if (answerFromServer) {
                                //Return error. Form error to be passed to completionHandler
                                NSError *error = [[NSError alloc] initWithDomain:NSMachErrorDomain
                                                                            code:404
                                                                        userInfo:answerFromServer];
                                completionHandler(problemDetails, error);
                                return;
                            }
                            
                            
                            //Extract problemDetails from JSON
                            //Parse JSON
                            problem = [[[EcomapFetcher parseJSONtoArray:JSON] objectAtIndex:ECOMAP_PROBLEM_DETAILS_DESCRIPTION] firstObject];
                            problemDetails = [[EcomapProblemDetails alloc] initWithProblem:problem];
                        }
                    }
                    
                    //Return problemDetails
                    completionHandler(problemDetails, error);
                }];
}

#pragma mark - Login
+ (void)loginWithEmail:(NSString *)email andPassword:(NSString *)password OnCompletion:(void (^)(EcomapLoggedUser *loggedUser, NSError *error))completionHandler
{
    //Set up session configuration
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfiguration setHTTPAdditionalHeaders:@{@"Content-Type" : @"application/json;charset=UTF-8"}];
    
    //Set up request
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[EcomapURLFetcher URLforLogin]];
    [request setHTTPMethod:@"POST"];
    
    //Create JSON data to send to  server
    NSDictionary *loginData = @{@"email" : email, @"password" : password};
    NSData *data = [NSJSONSerialization dataWithJSONObject:loginData options:0
                                                     error:nil];
    [self uploadDataTaskWithRequest:request
                           fromData:data
               sessionConfiguration:sessionConfiguration
                  completionHandler:^(NSData *JSON, NSError *error) {
                      EcomapLoggedUser *loggedUser = nil;
                      NSDictionary *userInfo = nil;
                      if (!error) {
                          //Parse JSON
                          userInfo = [EcomapFetcher parseJSONtoDictionary:JSON];
                          //Create EcomapLoggedUser object
                          loggedUser = [[EcomapLoggedUser alloc] initWithUserInfo:userInfo];
                          
                          if (loggedUser) {
                              NSLog(@"LogIN to ecomap success! %@", loggedUser.description);
                              
                              //Create cookie
                              NSHTTPCookie *cookie = [self createCookieForUser:[EcomapLoggedUser currentLoggedUser]];
                              if (cookie) {
                                  NSLog(@"Cookies created success!");
                                  //Put cookie to NSHTTPCookieStorage
                                  [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
                                  [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:@[cookie]
                                                                                     forURL:[EcomapURLFetcher URLforServer]
                                                                            mainDocumentURL:nil];
                              }
                          }
                      }
                      
                      //set up completionHandler
                      completionHandler(loggedUser, error);
                  }];
}

#pragma mark - Logout
+ (void)logoutUser:(EcomapLoggedUser *)loggedUser OnCompletion:(void (^)(BOOL result, NSError *error))completionHandler
{
    //Set up session configuration
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    [self dataTaskWithRequest:[NSURLRequest requestWithURL:[EcomapURLFetcher URLforLogout]]
         sessionConfiguration:sessionConfiguration
            completionHandler:^(NSData *JSON, NSError *error) {
               BOOL result;
               if (!error) {
                   //Read response Data (it is not JSON actualy, just plain text)
                   NSString *statusResponse =[[NSString alloc]initWithData:JSON encoding:NSUTF8StringEncoding];
                   result = [statusResponse isEqualToString:@"OK"] ? YES : NO;
                   NSLog(@"Logout %@!", statusResponse);
                   
                   //Clear coockies
                   NSArray * cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[EcomapURLFetcher URLforServer]];
                   for (NSHTTPCookie *cookie in cookies) {
                       [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
                   }
                   
                   //Set userDefaults @"isUserLogged" key to NO to delete EcomapLoggedUser object
                   if (loggedUser) {
                       NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                       [defaults setObject:@"NO" forKey:@"isUserLogged"];
                   }
               }
               completionHandler(result, error);
}];
  
}

#pragma mark - Data tasks
//Data task
+(void)dataTaskWithRequest:(NSURLRequest *)request sessionConfiguration:(NSURLSessionConfiguration *)configuration completionHandler:(void (^)(NSData *JSON, NSError *error))completionHandler
{
    //Create new session to download JSON file
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    //Perform download task on different thread
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                NSData *JSON = nil;
                                                if (!error) {
                                                    //Set data
                                                    if ([EcomapFetcher statusCodeFromResponse:response] == 200) {
                                                        //Log to console
                                                        NSLog(@"JSON data downloaded success from URL: %@", request.URL);
                                                        JSON = data;
                                                        
                                                    } else {
                                                        //Create error message
                                                        error = [EcomapFetcher errorForStatusCode:[EcomapFetcher statusCodeFromResponse:response]];
                                                    }
                                                }
                                                //Perform completionHandler task on main thread
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    completionHandler(JSON, error);
                                                });
                                            }];
    
    [task resume];
}

//Upload data task
+(void)uploadDataTaskWithRequest:(NSURLRequest *)request fromData:(NSData *)data sessionConfiguration:(NSURLSessionConfiguration *)configuration completionHandler:(void (^)(NSData *JSON, NSError *error))completionHandler
{
    //Create new session to download JSON file
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    //Perform upload task on different thread
    NSURLSessionUploadTask *task = [session uploadTaskWithRequest:request fromData:data completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSData *JSON = nil;
        if (!error) {
            //Set data
            if ([EcomapFetcher statusCodeFromResponse:response] == 200) {
                //Log to console
                NSLog(@"Data uploaded success to url: %@", request.URL);
                JSON = data;
            } else {
                //Create error message
                error = [EcomapFetcher errorForStatusCode:[EcomapFetcher statusCodeFromResponse:response]];
            }
        }
        //Perform completionHandler task on main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(JSON, error);
        });
    }];
    [task resume];
}

#pragma mark - Parse JSON
//Parse JSON data to Array
+ (NSArray *)parseJSONtoArray:(NSData *)JSON
{
    NSArray *dataFromJSON = nil;
    NSError *error = nil;
    id parsedJSON = [NSJSONSerialization JSONObjectWithData:JSON options:0 error:&error];
    if (!error) {
        if ([parsedJSON isKindOfClass:[NSArray class]]) {
            dataFromJSON = (NSArray *)parsedJSON;
        }
    } else {
        NSLog(@"Error parsing JSON data: %@", error);
    }
    
    return dataFromJSON;
}

//Parse JSON data to Dictionary
+ (NSDictionary *)parseJSONtoDictionary:(NSData *)JSON
{
    NSDictionary *dataFromJSON = nil;
    NSError *error = nil;
    id parsedJSON = [NSJSONSerialization JSONObjectWithData:JSON options:0 error:&error];
    if (!error) {
        if ([parsedJSON isKindOfClass:[NSDictionary class]]) {
            dataFromJSON = (NSDictionary *)parsedJSON;
        }
    } else {
        NSLog(@"Error parsing JSON data: %@", error);
    }
    
    return dataFromJSON;
}

#pragma mark - Helper methods
+(NSInteger)statusCodeFromResponse:(NSURLResponse *)response
{
    //Cast an instance of NSHTTURLResponse from the response and use its statusCode method
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    return httpResponse.statusCode;
}

//Form error for different status code. (Fill more case: if needed)
+(NSError *)errorForStatusCode:(NSInteger)statusCode
{
    
    NSError *error = nil;
    switch (statusCode) {
        case 400:
            error = [[NSError alloc] initWithDomain:@"Bad Request" code:statusCode userInfo:@{@"error" : @"Incorect email or password"}];
            break;
        
        case 401:
            error = [[NSError alloc] initWithDomain:@"Unauthorized" code:statusCode userInfo:@{@"error" : @"Authentication credentials were missing or incorrect"}];
            break;
            
        case 404:
            error = [[NSError alloc] initWithDomain:@"Not Found" code:statusCode userInfo:@{@"error" : @"The server has not found anything matching the Request URL"}];
            break;
            
        default:
            error = [[NSError alloc] initWithDomain:@"Unknown error" code:statusCode userInfo:@{@"error" : @"Unknown error"}];
            break;
    }
    return error;
}

+ (NSHTTPCookie *)createCookieForUser:(EcomapLoggedUser *)userData
{
    NSHTTPCookie *cookie = nil;
    if (userData) {
        //Form userName value
        NSString *userName = userData.name ? userData.name : @"null";
        NSString *userNameValue = [NSString stringWithFormat:@"userName=%@", userName];
        
        //Form userSurname value
        NSString *userSurname = userData.surname ? userData.surname : @"null";
        NSString *userSurnameValue = [NSString stringWithFormat:@"userSurname=%@", userSurname];
        
        //Form userRole value
        NSString *userRole = userData.role ? userData.role : @"null";
        NSString *userRoleValue = [NSString stringWithFormat:@"userRole=%@", userRole];
        
        //Form token value
        NSString *token = userData.token ? userData.token : @"null";
        NSString *tokenValue = [NSString stringWithFormat:@"token=%@", token];
        
        //Form id value
        NSString *idValue = [NSString stringWithFormat:@"id=%d", userData.userID];
        
        //Form userEmail value
        NSString *userEmail = userData.email ? [userData.email stringByReplacingOccurrencesOfString:@"@" withString:@"%"] : @"null";
        NSString *userEmailValue = [NSString stringWithFormat:@"userEmail=%@", userEmail];
        
        //Form cookie value
        NSString *cookieValue = [NSString stringWithFormat:@"%@; %@; %@; %@; %@; %@", userNameValue, userSurnameValue, userRoleValue, tokenValue, idValue, userEmailValue];
        
        //Form cookie properties
        NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [EcomapURLFetcher serverDomain], NSHTTPCookieDomain,
                                    @"/", NSHTTPCookiePath,
                                    @"ECOMAPCOOKIE", NSHTTPCookieName,
                                    cookieValue, NSHTTPCookieValue,
                                    [[NSDate date] dateByAddingTimeInterval:864000], NSHTTPCookieExpires, //10 days
                                    nil];
        
        //Form cookie
        cookie = [NSHTTPCookie cookieWithProperties:properties];
    }
    
    return cookie;
}


/*
 //Create new session to download JSON file
 NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
 //Perform download task on different thread
 NSURLSessionDataTask *task = [session dataTaskWithURL:url
 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
 NSMutableArray *problems = nil;
 NSArray *problemsFromJSON = nil;
 if (!error) {
 //Parse JSON
 problemsFromJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
 problems = [NSMutableArray array];
 for (NSDictionary *problem in problemsFromJSON) {
 EcomapProblem *ecoProblem = [[EcomapProblem alloc] initWithProblem:problem];
 [problems addObject:ecoProblem];
 }
 }
 //Perform completionHandler task on main thread
 dispatch_async(dispatch_get_main_queue(), ^{
 completionHandler(problems, error);
 });
 }];
 
 [task resume];
*/

/*
 NSURLSessionDownloadTask *task = [session downloadTaskWithURL:[EcomapURLFetcher URLforAllProblems] completionHandler:^(NSURL *localFile, NSURLResponse *response, NSError *error) {
 NSArray *problems = nil;
 if (!error) {
 //Parse JSON
 problems = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:localFile] options:0 error:&error];
 }
 //Perform completionHandler task on main thread
 dispatch_async(dispatch_get_main_queue(), ^{
 completionHandler(problems, error);
 });
 }];
*/


/*

#pragma mark - Sort Problems
//Sort problems array by "title" key
+ (NSArray *)sortProblems:(NSArray *)problems{
    return [problems sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *title1 = [obj1 valueForKeyPath:ECOMAP_PROBLEM_TITLE];
        NSString *title2 = [obj2 valueForKeyPath:ECOMAP_PROBLEM_TITLE];
        return [title1 compare:title2 options:NSCaseInsensitiveSearch];
    }];
}

#pragma mark - Dictionary for tableView cells
//Form new dictionary @"problem type" : problems(array)
+ (NSDictionary *)problemsByType:(NSArray *)problems
{
    NSMutableDictionary *problemsByType = [NSMutableDictionary dictionary];
    for (NSDictionary *problem in problems) {
        NSString *problemType = [self typeOfProblem:problem];
        NSMutableArray *problemsOfType = problemsByType[problemType];
        if (!problemsOfType) {
            problemsOfType = [NSMutableArray array];
            problemsByType[problemType] = problemsOfType;
        }
        [problemsOfType addObject:problem];
    }
    return problemsByType;
}

#pragma mark - Section for tableView
//Form array with problem types sorted alphabetically
+ (NSArray *)typesFromProblemsByType:(NSDictionary *)problemsByType
{
    NSArray *types = [problemsByType allKeys];
    types = [types sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 caseInsensitiveCompare:obj2];
    }];
    return types;
}

*/

@end
