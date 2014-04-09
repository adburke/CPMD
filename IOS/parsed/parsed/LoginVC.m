//
//  ViewController.m
//  parsed
//
//  Created by Aaron Burke on 4/2/14.
//  Copyright (c) 2014 Aaron Burke. All rights reserved.
//

#import "LoginVC.h"
#import <QuartzCore/QuartzCore.h>
#import "MainTableVC.h"
#import "AppDelegate.h"

@interface LoginVC ()

@property (strong, nonatomic) UIView *activityBg;
@property (strong, nonatomic) UIActivityIndicatorView *activityView;

@end

@implementation LoginVC


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    UIImage *bgImage = [UIImage imageNamed:@"skulls.png"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:bgImage];
    
    // Add corner radius to labels
    self.loginBg.layer.cornerRadius = 5;
    self.loginInputBg.layer.cornerRadius = 5;
    
    // Add just a bottom border to the email input
    CGRect layerFrame = CGRectMake(0, 0, self.emailInput.frame.size.width, self.emailInput.frame.size.height);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, layerFrame.size.height);
    CGPathAddLineToPoint(path, NULL, layerFrame.size.width, layerFrame.size.height); // bottom line
    CAShapeLayer * line = [CAShapeLayer layer];
    line.path = path;
    line.lineWidth = 2;
    line.frame = layerFrame;
    line.strokeColor = [UIColor lightGrayColor].CGColor;
    [self.emailInput.layer addSublayer:line];

}

- (IBAction)onPress:(id)sender
{
    UIButton *button = (UIButton*)sender;
    switch (button.tag) {
        case 0:
            NSLog(@"Login Selected");
            [self checkConnectivity];
            [self startActivity];
            
            BOOL emailTest = [self validEmail:self.emailInput.text];
            BOOL passwordTest = [self validPassword:self.passwordInput.text];
            
            if (emailTest && passwordTest) {
                [self parseLogin:self.emailInput.text password:self.passwordInput.text];
            } else {
                [self localErrorHandler:emailTest passwordTest:passwordTest];
                [self stopActivity];
            }
            
            break;
        case 1:
            NSLog(@"Register Selected");
            break;
        case 2:
            NSLog(@"Forgot PW Selected");
            break;
        default:
            break;
    }
}

- (void)localErrorHandler:(BOOL)emailTest passwordTest:(BOOL)passwordTest
{
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Validation Error" message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    
    NSLog(@"localErroHandler Launched");
    if (!emailTest && !passwordTest) {
        alertView.message = @"Email input was invalid and password input was empty.";
        [alertView show];
    }
}

- (void)checkConnectivity
{
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (appDelegate.isNetworkActive) {
        NSLog(@"Network is active");
    } else {
        NSLog(@"Network is not active");
    }
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

- (void)startActivity
{
    
    CGRect screenFrame = [self screenFrameForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    self.activityBg = [[UIView alloc] initWithFrame:screenFrame];
    self.activityBg.backgroundColor = [UIColor darkGrayColor];
    self.activityBg.alpha = 0.9;
    
    [self.view addSubview:self.activityBg];
    
    
    self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityView.center = CGPointMake( screenFrame.size.width / 2, screenFrame.size.height / 2);
    [self.activityView startAnimating];
    
    [self.view addSubview:self.activityView];
    
}

- (void)stopActivity
{
    [self.activityBg removeFromSuperview];
    [self.activityView removeFromSuperview];
}

- (BOOL)validEmail:(NSString*)emailStr
{
    
    if([emailStr length]==0){
        return NO;
    }
    
    NSString *regExPattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:emailStr options:0 range:NSMakeRange(0, [emailStr length])];
    
    NSLog(@"%i", regExMatches);
    if (regExMatches == 0) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)validPassword:(NSString*)passwordStr
{
    if([passwordStr length]==0){
        return NO;
    } else {
        return YES;
    }
}

- (void)parseLogin:(NSString*)emailStr password:(NSString*)passwordStr
{
    
    
    [PFUser logInWithUsernameInBackground:emailStr password:passwordStr block:^(PFUser *user, NSError *error)
    {
        if (user) {
            // Do stuff after successful login.
            NSLog(@"Login Success");
            [self stopActivity];
            [self dismissViewControllerAnimated:YES completion:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshTable" object:self];
        } else {
            // The login failed. Check error to see why.
            NSLog(@"Login Fail");
            [self stopActivity];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login Failure" message:@"Account not found or password incorrect" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
            
        }
    }];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (self.activityBg)
    {
        CGRect screenFrame = [self screenFrameForOrientation:toInterfaceOrientation];
        [self.activityBg setFrame:screenFrame];
        
        self.activityView.center = CGPointMake( screenFrame.size.width / 2, screenFrame.size.height / 2);
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
