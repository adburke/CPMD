//
//  RegisterVC.m
//  parsed
//
//  Created by Aaron Burke on 4/2/14.
//  Copyright (c) 2014 Aaron Burke. All rights reserved.
//

#import "RegisterVC.h"

@interface RegisterVC ()

@property (strong, nonatomic) UIView *activityBg;
@property (strong, nonatomic) UIActivityIndicatorView *activityView;

@end

@implementation RegisterVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImage *bgImage = [UIImage imageNamed:@"skulls.png"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:bgImage];
    
    // Add corner radius
    self.registerBg.layer.cornerRadius = 5;
    self.greyBgLabel.layer.cornerRadius = 5;
    
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
    
    // Add just a bottom border to the email input
    CGRect layerFrame2 = CGRectMake(0, 0, self.passwordInput.frame.size.width, self.passwordInput.frame.size.height);
    CGMutablePathRef path2 = CGPathCreateMutable();
    CGPathMoveToPoint(path2, NULL, 0, layerFrame2.size.height);
    CGPathAddLineToPoint(path2, NULL, layerFrame2.size.width, layerFrame2.size.height); // bottom line
    CAShapeLayer * line2 = [CAShapeLayer layer];
    line2.path = path2;
    line2.lineWidth = 2;
    line2.frame = layerFrame2;
    line2.strokeColor = [UIColor lightGrayColor].CGColor;
    [self.passwordInput.layer addSublayer:line2];
}

- (IBAction)onPress:(id)sender
{
    UIButton *button = (UIButton*)sender;
    switch (button.tag) {
        case 0:
            NSLog(@"Register Selected");
            
            [self startActivity];
            
            
            BOOL emailTest = [self validEmail:self.emailInput.text];
            BOOL passwordTest = [self validPassword:self.passwordInput.text];
            BOOL confirmTest = [self validPassword:self.confirmPassInput.text];
            BOOL matchTest = [self validePasswordMatch:self.passwordInput.text confirmPassStr:self.confirmPassInput.text];
            
            if (emailTest && matchTest) {
                // Register with parse
                [self parseRegistration:self.emailInput.text password:self.passwordInput.text];
                
            } else {
                [self localErrorHandler:emailTest passwordTest:passwordTest confirmTest:confirmTest passwordMatch:matchTest];
                [self stopActivity];
            }
            
            break;
        case 1:
            NSLog(@"Cancel Selected");
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        default:
            break;
    }
}

- (BOOL)validEmail:(NSString*)emailString
{
    
    if([emailString length]==0){
        return NO;
    }
    
    NSString *regExPattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:emailString options:0 range:NSMakeRange(0, [emailString length])];
    
    NSLog(@"%i", regExMatches);
    if (regExMatches == 0) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)validPassword:(NSString*)passwordStr
{
    if([passwordStr length] == 0){
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)validePasswordMatch:(NSString*)passwordStr confirmPassStr:(NSString*)confirmPassStr
{
    if ([passwordStr isEqualToString:confirmPassStr] && passwordStr.length != 0 && confirmPassStr.length != 0) {
        return YES;
    } else {
        return NO;
    }
}

- (void)viewWillLayoutSubviews
{
    
    [super viewWillLayoutSubviews];
    self.view.superview.bounds = CGRectMake(0, 0, 600, 450);
    self.view.superview.layer.cornerRadius  = 20.0;
    self.view.superview.layer.masksToBounds = YES;
}

- (void)localErrorHandler:(BOOL)emailTest
             passwordTest:(BOOL)passwordTest
              confirmTest:(BOOL)confirmTest
            passwordMatch:(BOOL)passwordMatch
{
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Validation Error" message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    
    NSLog(@"localErroHandler Launched");
    if (!emailTest) {
        alertView.message = @"Email input was invalid.";
    } else if (!passwordTest){
        alertView.message = @"Password field was empty";
    } else if (!confirmTest){
        alertView.message = @"Confirm password field was empty";
    } else if (!passwordMatch) {
        alertView.message = @"Password inputs do not match";
    }
    
    [alertView show];
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
    
}

- (void)stopActivity
{
    [self.activityBg removeFromSuperview];
    [self.activityView removeFromSuperview];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (self.activityBg)
    {
        CGRect screenFrame = [self screenFrameForOrientation:toInterfaceOrientation];
        [self.activityBg setFrame:screenFrame];
        
        self.activityView.center = self.view.center;
    }
}

- (void)parseRegistration:(NSString*)emailStr password:(NSString*)passwordStr
{
    PFUser *user = [PFUser user];
    user.username = emailStr;
    user.password = passwordStr;
    user.email = emailStr;
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            // Hooray! Let them use the app now.
            [self stopActivity];
            [[[self presentingViewController] presentingViewController] dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self stopActivity];
            NSString *errorString = [error userInfo][@"error"];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Validation Error" message:errorString delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
        }
    }];
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

@end
