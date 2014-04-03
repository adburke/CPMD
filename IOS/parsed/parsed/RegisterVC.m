//
//  RegisterVC.m
//  parsed
//
//  Created by Aaron Burke on 4/2/14.
//  Copyright (c) 2014 Aaron Burke. All rights reserved.
//

#import "RegisterVC.h"

@interface RegisterVC ()

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

- (BOOL)validPassword:(NSString*)passwordString
{
    if([passwordString length]==0){
        return NO;
    } else {
        return YES;
    }
}

- (void)viewWillLayoutSubviews
{
    
    [super viewWillLayoutSubviews];
    self.view.superview.bounds = CGRectMake(0, 0, 600, 450);
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

@end
