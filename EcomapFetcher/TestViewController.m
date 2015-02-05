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
