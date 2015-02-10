//
//  EcomapURLFetcher.h
//  EcomapFetcher
//
//  Created by Vasilii Kotsiuba on 2/3/15.
//  Copyright (c) 2015 Vasyl Kotsiuba. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EcomapURLFetcher : NSObject

//Return server domain
+ (NSString *)serverDomain;

//Return URL to servet
+ (NSURL *)URLforServer;

//Return API URL to get all problems
+ (NSURL *)URLforAllProblems;

//Return API URL to get problem with ID
+ (NSURL *)URLforProblemWithID:(NSUInteger)problemID;

//Return API URL to logIn
+ (NSURL *)URLforLogin;

//Return API URL to logout
+ (NSURL *)URLforLogout;

@end
