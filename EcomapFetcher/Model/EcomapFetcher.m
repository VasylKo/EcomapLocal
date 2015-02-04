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
    [self loadDataTaskWithRequest:[NSURLRequest requestWithURL:[EcomapURLFetcher URLforAllProblems]]
         sessionConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]
            completionHandler:^(NSData *JSON, NSError *error) {
                NSMutableArray *problems = nil;
                NSArray *problemsFromJSON = nil;
                if (!error) {
                    //Extract received data
                    if (JSON != nil) {
                        //Parse JSON
                        id parsedJSON = [NSJSONSerialization JSONObjectWithData:JSON options:0 error:&error];
                        if ([parsedJSON isKindOfClass:[NSArray class]]) {
                            problemsFromJSON = (NSArray *)parsedJSON;
                        }
                        
                        //Fill problems array
                        if (problemsFromJSON) {
                            problems = [NSMutableArray array];
                            //Fill array with EcomapProblem
                            for (NSDictionary *problem in problemsFromJSON) {
                                EcomapProblem *ecoProblem = [[EcomapProblem alloc] initWithProblem:problem];
                                [problems addObject:ecoProblem];
                            }
                        }
                    
                    } else {
                        //No data was received. Form error message
                        error = [EcomapFetcher errorForStatusCode:500];
                    }
                    
                }
                //set up completionHandler
                completionHandler(problems, error);
            }];

}

#pragma mark - Load Problem with ID
+ (void)loadProblemDetailsWithID:(NSUInteger)problemID OnCompletion:(void (^)(EcomapProblemDetails *problemDetails, NSError *error))completionHandler
{
    [self loadDataTaskWithRequest:[NSURLRequest requestWithURL:[EcomapURLFetcher URLforProblemWithID:problemID]]
         sessionConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]
            completionHandler:^(NSData *JSON, NSError *error) {
                NSDictionary *problem = nil;
                EcomapProblemDetails *problemDetails = nil;
                if (!error) {
                    //Extract received data
                    if (JSON != nil) {
                        //Check if we have a problem with such problemID
                        //Parse JSON
                        id answer = [NSJSONSerialization JSONObjectWithData:JSON options:0 error:&error];
                        if ([answer isKindOfClass:[NSDictionary class]]) {
                            //Return error
                            NSError *err = [[NSError alloc] initWithDomain:NSMachErrorDomain code:404 userInfo:answer];
                            completionHandler(problemDetails, err);
                            return;
                        }
                        
                        //Extract problemDetails from JSON
                        //Parse JSON
                        //Parse JSON
                        id parsedJSON = [NSJSONSerialization JSONObjectWithData:JSON options:0 error:&error];
                        if ([parsedJSON isKindOfClass:[NSArray class]]) {
                            problem = (NSDictionary *)[[parsedJSON objectAtIndex:ECOMAP_PROBLEM_DETAILS_DESCRIPTION] firstObject];
                        }
                        problemDetails = [[EcomapProblemDetails alloc] initWithProblem:problem];
                    } else {
                        //No data was received. Form error message
                        error = [EcomapFetcher errorForStatusCode:500];
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
                          userInfo = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:JSON options:0 error:&error];
                          loggedUser = [[EcomapLoggedUser alloc] initWithUserInfo:userInfo];
                      }
                      
                      //set up completionHandler
                      completionHandler(loggedUser, error);
                  }];
}

#pragma mark - Load data task
+(void)loadDataTaskWithRequest:(NSURLRequest *)request sessionConfiguration:(NSURLSessionConfiguration *)configuration completionHandler:(void (^)(NSData *JSON, NSError *error))completionHandler
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

#pragma mark - upLoad data task
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

#pragma mark - Get status code
+(NSInteger)statusCodeFromResponse:(NSURLResponse *)response
{
    //Cast an instance of NSHTTURLResponse from the response and use its statusCode method
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    //NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
    return httpResponse.statusCode;
}

#pragma mark - Form error for status code
//Form error for different status code. (Fill more case: if needed)
+(NSError *)errorForStatusCode:(NSInteger)statusCode
{
    
    NSError *error = nil;
    switch (statusCode) {
        case 400:
            error = [[NSError alloc] initWithDomain:@"Bad Request" code:statusCode userInfo:@{@"error" : @"Incorect email or password"}];
            break;
        
        case 404:
            error = [[NSError alloc] initWithDomain:@"Not Found" code:statusCode userInfo:@{@"error" : @"The server has not found anything matching the Request URL"}];
            break;
            
        case 500:
            error = [[NSError alloc] initWithDomain:@"No data received" code:statusCode userInfo:@{@"error" : @"No data received from server"}];
            break;
        
        default:
            error = [[NSError alloc] initWithDomain:@"Unknown error" code:statusCode userInfo:@{@"error" : @"Unknown error"}];
            break;
    }
    return error;
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
