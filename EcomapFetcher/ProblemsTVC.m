//
//  ProblemsTVC.m
//  EcomapFetcher
//
//  Created by Vasya on 2/1/15.
//  Copyright (c) 2015 Vasyl Kotsiuba. All rights reserved.
//

#import "ProblemsTVC.h"
#import "EcomapFetcher.h"

@interface ProblemsTVC ()
@property (nonatomic, strong) NSArray *problems; //of NSDictionaries
@property (nonatomic, strong) NSDictionary *problemsByType; //Key - string, value - array of Dictionaries
@property (nonatomic, strong) NSArray *types; //of Strings

@end

@implementation ProblemsTVC

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    //[self refreshProblemsCell];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

/*

#pragma mark - View life cycle
- (IBAction)refreshProblemsCell {
    [self.refreshControl beginRefreshing];
    [EcomapGETHelper loadAllProblemsOnCompletion:^(NSArray *problems, NSError *error) {
        if (!error) {
            self.problems = problems;
            [self.refreshControl endRefreshing];
        } else {
            NSLog(@"Error loading problems: %@", error);
        }
        
    }];
}

#pragma mark - Accessors
-(void)setProblems:(NSArray *)problems
{
    //if array is same do nothing
    if (problems == _problems) return;
    _problems = [EcomapGETHelper sortProblems:problems];
    self.problemsByType = [EcomapGETHelper problemsByType:_problems];
    self.types = [EcomapGETHelper typesFromProblemsByType:self.problemsByType];
    [self.tableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [self.types count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.problemsByType[self.types[section]] count];
}

#pragma mark - Section Header
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.types[section];
}


#pragma mark - Table view cell data
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Problem Cell"
                                                            forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *problem = self.problemsByType[self.types[indexPath.section]][indexPath.row];
    cell.textLabel.text = [EcomapGETHelper titleOfProblem:problem];
    cell.detailTextLabel.text = [EcomapGETHelper subtitleOfProblem:problem];
    cell.imageView.image = [EcomapGETHelper isSolvedProblem:problem] ? [UIImage imageNamed:@"star"] : [UIImage imageNamed:@"lightbulb"];
    return cell;
}

 */

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



@end
