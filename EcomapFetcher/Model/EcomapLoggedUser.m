//
//  EcomapLoggedUser.m
//  EcomapFetcher
//
//  Created by Vasya on 2/3/15.
//  Copyright (c) 2015 Vasyl Kotsiuba. All rights reserved.
//

#import "EcomapLoggedUser.h"
#import "EcomapPathDefine.h"

EcomapLoggedUser *currentLoggedUser = nil;

@interface EcomapLoggedUser ()
@property (nonatomic, readwrite) NSUInteger userID;
@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, strong, readwrite) NSString *surname;
@property (nonatomic, strong, readwrite) NSString *role;
@property (nonatomic, readwrite) NSUInteger iat;
@property (nonatomic, strong, readwrite) NSString *token;
@property (nonatomic, strong, readwrite) NSString *email;

@end

@implementation EcomapLoggedUser
#pragma mark - Return current clas instanse
+(EcomapLoggedUser *)currentLoggedUser
{
    return currentLoggedUser;
}

#pragma mark - Logout
+(void)logout
{
    currentLoggedUser = nil;
}

#pragma mark - Private initializer
-(instancetype)initWithUserInfo:(NSDictionary *)userInfo
{
    self = [super init];
    if (self) {
        if (userInfo){
            [self parseUser:userInfo];
            currentLoggedUser = self;
        } else {
            currentLoggedUser = nil;
            return nil;
        }
    }

    return self;
}

//Disable init method
-(instancetype)init
{
    @throw [NSException exceptionWithName:@"Error" reason:@"Can't create instanse of this class. To login to server use EcomapFetcher class" userInfo:nil];
    return nil;
}

#pragma mark - Parse userInfo
-(void)parseUser:(NSDictionary *)userInfo
{
    if (userInfo) {
        self.userID = [[userInfo valueForKey:ECOMAP_USER_ID] integerValue];
        self.name = [userInfo valueForKey:ECOMAP_USER_NAME];
        self.surname = [userInfo valueForKey:ECOMAP_USER_SURNAME];
        self.role = [userInfo valueForKey:ECOMAP_USER_ROLE];
        self.iat = [[userInfo valueForKey:ECOMAP_USER_ITA] integerValue];
        self.token = [userInfo valueForKey:ECOMAP_USER_TOKEN];
        self.email = [userInfo valueForKey:ECOMAP_USER_EMAIL];
    }
}

#pragma mark - Override description
//Override
-(NSString *)description
{
    return [NSString stringWithFormat:@"Logged user: %@", self.name];
}

@end
