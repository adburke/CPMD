//
//  ViewController.m
//  parsed
//
//  Created by Aaron Burke on 4/2/14.
//  Copyright (c) 2014 Aaron Burke. All rights reserved.
//

#import "LoginVC.h"
#import <QuartzCore/QuartzCore.h>

@interface LoginVC ()

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
