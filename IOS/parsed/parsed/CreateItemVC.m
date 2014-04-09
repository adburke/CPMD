//
//  CreateItemVC.m
//  parsed
//
//  Created by Aaron Burke on 4/3/14.
//  Copyright (c) 2014 Aaron Burke. All rights reserved.
//

#import "CreateItemVC.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "EntryData.h"
#import "EntryManager.h"

@interface CreateItemVC ()

@property (nonatomic, strong) UIView *activityBg;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, assign) BOOL messageCheck;
@property (nonatomic, assign) BOOL nameCheck;
@property (nonatomic, assign) BOOL numberCheck;
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) EntryManager *entryManager;


@end

@implementation CreateItemVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Get reference to appdelegate for network connectivity check
    self.appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.entryManager = [EntryManager sharedInstance];
    
    UIImage *bgImage = [UIImage imageNamed:@"skulls.png"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:bgImage];
    
    // Add corner radius
    self.greyBg.layer.cornerRadius = 5;
    self.whiteBg.layer.cornerRadius = 5;
}

- (void)viewWillLayoutSubviews
{
    
    [super viewWillLayoutSubviews];
    self.view.superview.bounds = CGRectMake(0, 0, 600, 400);
    self.view.superview.layer.cornerRadius  = 20.0;
    self.view.superview.layer.masksToBounds = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onPress:(id)sender
{
    UIButton *button = (UIButton*)sender;
    switch (button.tag) {
        {case 0:
            NSLog(@"Create Selected");
            
            [self startActivity];

            self.messageCheck = [self validateMessage:self.messageInput.text];
            self.nameCheck = [self validateName:self.nameInput.text];
            
            NSNumberFormatter * nf = [[NSNumberFormatter alloc] init];
            [nf setNumberStyle:NSNumberFormatterDecimalStyle];
            NSNumber *number = [nf numberFromString:self.randomNumInput.text];
            self.numberCheck = [self validateNumber:number];
            
            if (self.messageCheck && self.nameCheck && self.numberCheck) {
                [self createItem:self.messageInput.text nameStr:self.nameInput.text number:number];
            } else {
                [self localErrorHandler:self.messageCheck nameCheck:self.nameCheck numberCheck:self.numberCheck];
                [self stopActivity];
            }
            
            break;
        }
            
        {case 1:
            NSLog(@"Cancel Selected");
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }
        default:
            break;
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (!self.messageCheck || !self.nameCheck || !self.numberCheck) {
        
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshTable" object:self];
    }

}

- (void)createItem:(NSString*)messageStr nameStr:(NSString*)nameStr number:(NSNumber*)number
{
    // Local object creation
    EntryData *entryLocal = [[EntryData alloc] initWithMessage:messageStr name:nameStr number:number];
    
    [self.entryManager saveEntryData:entryLocal isNewCache:NO];
}

//- (void)saveToParse:(PFObject*)entryParse
//{
//    
//    if (self.appDelegate.isNetworkActive) {
//        // Save now
//        [entryParse saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//            
//            if (!error) {
//                // Show success message
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload Complete" message:@"Successfully saved entry" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                [alert show];
//                
//            } else {
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload Failure" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                [alert show];
//                
//            }
//            
//        }];
//    } else {
//        // Save later when network is re-established
//        [entryParse saveEventually];
//        
//    }
//}

- (BOOL)validateMessage:(NSString*)messageStr
{
    if ([messageStr length] < 10) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)validateName:(NSString*)nameStr
{
    if ([nameStr length] == 0) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)validateNumber:(NSNumber*)number
{
    if ([number isEqualToNumber:[NSDecimalNumber notANumber]]) {
        return NO;
    } else {
        return YES;
    }
}

- (void)localErrorHandler:(BOOL)messageCheck
             nameCheck:(BOOL)nameCheck
              numberCheck:(BOOL)numberCheck
{
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Validation Error" message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    
    NSLog(@"localErroHandler Launched");
    if (!messageCheck) {
        alertView.message = @"Message was empty or less than 10 characters.";
    } else if (!nameCheck){
        alertView.message = @"Name field was empty";
    } else if (!numberCheck){
        alertView.message = @"Input was not a number";
    }
    
    [alertView show];
}

- (void)stopActivity
{
    [self.activityBg removeFromSuperview];
    [self.activityView removeFromSuperview];
}

- (void)startActivity
{
    
    CGRect screenFrame = [self screenFrameForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    self.activityBg = [[UIView alloc] initWithFrame:screenFrame];
    self.activityBg.backgroundColor = [UIColor darkGrayColor];
    self.activityBg.alpha = 0.9;
    
    [self.view addSubview:self.activityBg];
    
    
    self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityView.center = self.view.center;
    [self.activityView startAnimating];
    
    [self.view addSubview:self.activityView];
    [self.view bringSubviewToFront:self.activityView];
    
}

- (CGRect)screenFrameForOrientation:(UIInterfaceOrientation)orientation {
    CGRect appFrame = [[UIScreen mainScreen] bounds];
    CGRect screenFrame;
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        //Handle landscape orientation
        screenFrame =  CGRectMake(0.0, 0.0, appFrame.size.height, appFrame.size.width);
    }
    else {
        //Handle portrait orientation
        screenFrame = CGRectMake(0.0, 0.0, appFrame.size.width, appFrame.size.height);
    }
    return screenFrame;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (self.activityBg)
    {
        CGRect screenFrame = [self screenFrameForOrientation:toInterfaceOrientation];
        [self.activityBg setFrame:screenFrame];
        
//        self.activityView.center = CGPointMake( screenFrame.size.width / 2, screenFrame.size.height / 2);
        self.activityView.center = self.view.center;
    }
}

@end
