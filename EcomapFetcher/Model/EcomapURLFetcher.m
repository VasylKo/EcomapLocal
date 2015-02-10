//
//  EcomapURLFetcher.m
//  EcomapFetcher
//
//  Created by Vasilii Kotsiuba on 2/3/15.
//  Copyright (c) 2015 Vasyl Kotsiuba. All rights reserved.
//

#import "EcomapURLFetcher.h"
#import "EcomapPathDefine.h"

@implementation EcomapURLFetcher

#pragma mark - Form final URL
//Add Server adress
+ (NSURL *)URLForQuery:(NSString *)query
{
    query = [NSString stringWithFormat:@"%@%@", ECOMAP_ADDRESS, query];
    query = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [NSURL URLWithString:query];
}

//Add API address
+ (NSURL *)URLForAPIQuery:(NSString *)query
{
    query = [NSString stringWithFormat:@"%@%@", ECOMAP_API, query];
    return [self URLForQuery:query];
}

#pragma mark - Ask URL methods
+ (NSURL *)URLforAllProblems
{
    return [self URLForAPIQuery:ECOMAP_GET_PROBLEMS_API];
}

+ (NSURL *)URLforProblemWithID:(NSUInteger)problemID
{
    NSString *query = [NSString stringWithFormat:@"%@%lu", ECOMAP_GET_PROBLEMS_API, (unsigned long)problemID];
    return [self URLForAPIQuery:query];
}

+ (NSURL *)URLforLogin
{
    return [self URLForAPIQuery:ECOMAP_POST_LOGIN_API];
}

+ (NSURL *)URLforLogout
{
    return [self URLForAPIQuery:ECOMAP_GET_LOGOUT_API];
}

+ (NSURL *)URLforServer
{
    return [self URLForQuery:@""];
}

+ (NSString *)serverDomain
{
    NSString *domain = [ECOMAP_ADDRESS stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    
    return [domain stringByReplacingOccurrencesOfString:@"/" withString:@""];
}

@end
