//
//  EcomapProblem.m
//  EcomapFetcher
//
//  Created by Vasilii Kotsiuba on 2/3/15.
//  Copyright (c) 2015 Vasyl Kotsiuba. All rights reserved.
//

#import "EcomapProblem.h"
#import "EcomapPathDefine.h"

@interface EcomapProblem ()
@property (nonatomic, readwrite) NSUInteger problemID;
@property (nonatomic, strong, readwrite) NSString *title;
@property (nonatomic, readwrite) double latitude;
@property (nonatomic, readwrite) double longtitude;
@property (nonatomic, readwrite) NSUInteger problemTypesID;
@property (nonatomic, strong, readwrite) NSString *problemTypeTitle;
@property (nonatomic, readwrite) BOOL isSolved;
@property (nonatomic, strong, readwrite) NSString *dateCreated;
@end

@implementation EcomapProblem

#pragma mark - Designated initializer
-(instancetype)initWithProblem:(NSDictionary *)problem
{
    self = [super init];
    if (self) {
        if (!problem) return nil;
        [self parseProblem:problem];
    }
    return self;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Error" reason:@"Use designated initializer -initWithProblem:" userInfo:nil];
    return nil;
}

#pragma mark - Parsing problem
-(void)parseProblem:(NSDictionary *)problem
{
    if (problem) {
        self.problemID = [[problem valueForKey:ECOMAP_PROBLEM_ID] integerValue];
        self.title = [problem valueForKey:ECOMAP_PROBLEM_TITLE];
        self.latitude = [[problem valueForKey:ECOMAP_PROBLEM_LATITUDE] doubleValue];
        self.longtitude = [[problem valueForKey:ECOMAP_PROBLEM_LONGITUDE] doubleValue];
        self.problemTypesID = [[problem valueForKey:ECOMAP_PROBLEM_TYPE_ID] integerValue];
        self.problemTypeTitle = [ECOMAP_PROBLEM_TYPES_ARRAY objectAtIndex:(self.problemTypesID - 1)];
        self.isSolved = [[problem valueForKey:ECOMAP_PROBLEM_STATUS] integerValue] == 0 ? NO : YES;
        self.dateCreated = [self dateCreatedOfProblem:problem];
    }
}

//Returns problem's date added
- (NSString *)dateCreatedOfProblem:(NSDictionary *)problem
{
    NSString *date = (NSString *)[problem valueForKey:ECOMAP_PROBLEM_DATE];
    if (date) {
        return date;
    }
    return nil;
}

@end
