//
//  TestViewController.m
//  EcomapFetcher
//
//  Created by Vasilii Kotsiuba on 2/3/15.
//  Copyright (c) 2015 Vasyl Kotsiuba. All rights reserved.
//

#import "TestViewController.h"
#import "EcomapFetcher.h"
#import "EcomapProblemDetails.h"
#import "EcomapLoggedUser.h"

@interface TestViewController ()
@property (nonatomic, strong) NSArray *problems;
@property (nonatomic, strong) EcomapProblemDetails *problemDetails;

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadProblems];
    [self login];
    //[self dateParsing];
}

-(void)dateParsing
{
    //Case 1
     NSString *dateString = @"2014-02-18T07:15:51.000Z";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.'000Z'"];
    NSDate *cDate = [dateFormatter dateFromString:dateString];
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
    dateFormatter1.timeStyle = NSDateFormatterShortStyle;
    dateFormatter1.dateStyle = NSDateFormatterMediumStyle;
    NSLog(@"Date is %@", [dateFormatter1 stringFromDate:cDate]);
    
    /*
    NSString *dateString = @"2010-11-28T20:30:49Z";
    if ([dateString hasSuffix:@"Z"]) {
        dateString = [[dateString substringToIndex:(dateString.length-1)] stringByAppendingString:@"-0000"];
    }
    return [dateFromString:dateString
                     withFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    

   
    //NSDate *date = [NSDateFormatter alloc] ini
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDate *date = [dateFormatter dateFromString:dateString];
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    
    //NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:118800];
    
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:usLocale];
    
    NSLog(@"Date for locale %@: %@",
          [[dateFormatter locale] localeIdentifier], [dateFormatter stringFromDate:date]);
     */
}

-(void)login
{
    [EcomapFetcher loginWithEmail:@"admin@.com"
                      andPassword:@"admin"
                     OnCompletion:^(EcomapLoggedUser *user, NSError *error) {
                         if (!error) {
                             
                             NSLog(@"Login success! %@", user);
                             //Read current logged user
                             EcomapLoggedUser *loggedUser = [EcomapLoggedUser currentLoggedUser];
                             NSLog(@"Token: %@", loggedUser.token);
                             //Logout
                             [EcomapLoggedUser logout];
                             EcomapLoggedUser *loggedUser2 = [EcomapLoggedUser currentLoggedUser];
                             NSLog(@"Token: %@", loggedUser2.token);
                         } else {
                             NSLog(@"Error loading problems: %@", error);
                         }
                     }];
}

-(void)loadProblems
{
    [EcomapFetcher loadAllProblemsOnCompletion:^(NSArray *problems, NSError *error) {
        if (!error) {
            self.problems = problems;
            NSLog(@"Loaded success! %d problems", [self.problems count] + 1);
        } else {
            NSLog(@"Error loading problems: %@", error);
        }
        
    }];
    
    [EcomapFetcher loadProblemDetailsWithID:2
                               OnCompletion:^(EcomapProblemDetails *problemDetails, NSError *error) {
                                   if (!error) {
                                       self.problemDetails = problemDetails;
                                       NSLog(@"Loaded success! Details for 1 problem");
                                       NSLog(@"Titile %@", problemDetails.title);
                                   } else {
                                       NSLog(@"Error loading problem details: %@", error);
                                   }
                               }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
