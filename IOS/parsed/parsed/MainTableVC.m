//
//  MainTableVC.m
//  parsed
//
//  Created by Aaron Burke on 4/3/14.
//  Copyright (c) 2014 Aaron Burke. All rights reserved.
//

#import "MainTableVC.h"
#import "LoginVC.h"
#import "EntryCell.h"
#import <Parse/Parse.h>
#import "EntryManager.h"
#import "AppDelegate.h"

@interface MainTableVC ()

@property (nonatomic, strong) NSArray *entryObjects;
@property (nonatomic, strong) EntryManager *entryManager;
@property (nonatomic, strong) AppDelegate *appDelegate;

@end

@implementation MainTableVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    
//    self.navigationItem.rightBarButtonItem  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadData)
                                                 name:@"refreshTable"
                                               object:nil];
    
    
    self.appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.entryManager = [EntryManager sharedInstance];
    
    self.entryObjects = [[NSArray alloc] init];
    
    PFUser *currentUser = [PFUser currentUser];
    
    if (currentUser) {
        // Check if local data is available and load that first else check on Parse.com
        if ([self.entryManager.entryArray count] != 0) {
            self.entryObjects = [self.entryManager.entryArray copy];
            [self.tableView reloadData];
        } else if (self.appDelegate.isNetworkActive) {
            PFQuery *query = [PFQuery queryWithClassName:@"Entry"];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    // The find succeeded.
                    NSLog(@"Successfully retrieved %d entryies.", objects.count);
                    // Do something with the found objects
                    self.entryObjects = [objects copy];
                    
                    // Create local cache from Parse DB data if cache is empty
                    [self.entryManager createDataFromParse:[objects copy]];
                    
                    [self.tableView reloadData];
                } else {
                    // Log details of the failure
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
            
        }
    }
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    PFUser *currentUser = [PFUser currentUser];
    if (!currentUser) {
        self.entryObjects = nil;
        LoginVC *loginVc = [self.storyboard instantiateViewControllerWithIdentifier:@"loginVc"];
        [self presentViewController:loginVc animated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadData
{
    if (self.entryManager.entryArray != NULL) {
        self.entryObjects = [self.entryManager.entryArray copy];
        [self.tableView reloadData];
    } else if (self.appDelegate.isNetworkActive) {
        PFQuery *query = [PFQuery queryWithClassName:@"Entry"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                NSLog(@"Successfully retrieved %d entryies.", objects.count);
                // Do something with the found objects
                self.entryObjects = [objects copy];
                [self.tableView reloadData];
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
        
    }

}

- (IBAction)onPress:(id)sender
{
    UIBarButtonItem *button = (UIBarButtonItem*)sender;
    switch (button.tag) {
        case 0:
            break;
            
        {case 1:
            NSLog(@"Log Out selected");
            
            [PFUser logOut];
            
            self.entryObjects = nil;
            [self.tableView reloadData];
            
            LoginVC *loginVc = [self.storyboard instantiateViewControllerWithIdentifier:@"loginVc"];
            [self presentViewController:loginVc animated:YES completion:nil];
            
            break;
        }
            
        default:
            break;
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return self.entryObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EntryCell";
    EntryCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell) {
        if (self.entryManager.entryArray != NULL) {
            cell.name.text = [self.entryObjects[indexPath.row] valueForKey:@"name"];
            cell.message.text = [self.entryObjects[indexPath.row] valueForKey:@"message"];
            NSNumber *number = [self.entryObjects[indexPath.row] valueForKey:@"number"];
            cell.number.text =[number stringValue];
        } else {
            cell.name.text = [self.entryObjects[indexPath.row] objectForKey:@"name"];
            cell.message.text = [self.entryObjects[indexPath.row] objectForKey:@"message"];
            NSNumber *number = [self.entryObjects[indexPath.row] objectForKey:@"number"];
            cell.number.text =[number stringValue];
        }
    }
    
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self.entryManager deleteEntryData:self.entryObjects[indexPath.row]];
        self.entryObjects = [self.entryManager.entryArray copy];
         
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
