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
#import "CreateItemVC.h"

@interface MainTableVC ()

@property (nonatomic, strong) NSArray *entryObjects;
@property (nonatomic, strong) EntryManager *entryManager;
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSTimer *timer;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadData)
                                                 name:@"refreshTable"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sendParseData)
                                                 name:@"networkActive"
                                               object:nil];
    
    
    self.appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.entryManager = [EntryManager sharedInstance];
    
    self.entryObjects = [[NSArray alloc] init];
    
    // 20sec polling for updates
    self.timer = [NSTimer scheduledTimerWithTimeInterval:20.0 target:self
                                                    selector:@selector(reloadData) userInfo:nil repeats:YES];
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    PFUser *currentUser = [PFUser currentUser];
    if (!currentUser) {
        self.entryObjects = nil;
        LoginVC *loginVc = [self.storyboard instantiateViewControllerWithIdentifier:@"loginVc"];
        [self presentViewController:loginVc animated:YES completion:nil];
    } else {
        [self reloadData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadData
{
    if (self.appDelegate.isNetworkActive) {
        BOOL status = [self.entryManager isUpdateAvailable];
        if (status) {
            PFQuery *query = [PFQuery queryWithClassName:@"Entry"];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    // The find succeeded.
                    NSLog(@"Successfully retrieved %d entryies.", (int)objects.count);
                    // Clear everything out for the sake of this demo * not good otherwise
                    [self.entryManager newDataUpdate];
                    
                    [self.entryManager createDataFromParse:[objects copy]];
                    self.entryObjects = [self.entryManager.entryArray copy];
                    [self.tableView reloadData];
                } else {
                    // Log details of the failure
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
            return;
        }
    }
    
    // Check if local data is available and load that first else check on Parse.com
    if ([self.entryManager.entryArray count] != 0) {
        self.entryObjects = [self.entryManager.entryArray copy];
        [self.tableView reloadData];
    } else if (self.appDelegate.isNetworkActive) {
        PFQuery *query = [PFQuery queryWithClassName:@"Entry"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                NSLog(@"Successfully retrieved %d entryies.", (int)objects.count);
                
                // Create local cache from Parse DB data if cache is empty
                [self.entryManager createDataFromParse:[objects copy]];
                self.entryObjects = [self.entryManager.entryArray copy];
                [self.tableView reloadData];
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
        
    }

}

- (void)sendParseData {
    NSLog(@"sendParseData fired");
    if ([self.entryManager.offlineSavedArray count] != 0) {
        [self.entryManager updateParseWithSavedData];
        NSLog(@"sendParseData: fired EntryManager updateParseWithSavedData");
    } else{
        NSLog(@"sendParseData: no data to send");
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

        cell.name.text = [self.entryObjects[indexPath.row] valueForKey:@"name"];
        cell.message.text = [self.entryObjects[indexPath.row] valueForKey:@"message"];
        NSNumber *number = [self.entryObjects[indexPath.row] valueForKey:@"number"];
        cell.number.text =[number stringValue];

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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    CreateItemVC *destinationVC = segue.destinationViewController;
    
    if ([segue.identifier isEqualToString:@"createEntry"]) {
        if (destinationVC) {
            destinationVC.createDataBtnStr = @"CREATE";
            destinationVC.pageTitleStr = @"create entry";
            destinationVC.isCreating = YES;
        }
    } else if ([segue.identifier isEqualToString:@"editEntry"]) {
        if (destinationVC) {
            destinationVC.createDataBtnStr = @"EDIT";
            destinationVC.pageTitleStr = @"edit entry";
            destinationVC.isCreating = NO;
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            destinationVC.entryToEdit = [self.entryObjects objectAtIndex:indexPath.row];
        }
    }
    
}


@end
