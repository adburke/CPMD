//
//  ViewController.h
//  parsed
//
//  Created by Aaron Burke on 4/2/14.
//  Copyright (c) 2014 Aaron Burke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface LoginVC : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *loginBg;
@property (weak, nonatomic) IBOutlet UILabel *loginInputBg;

@property (weak, nonatomic) IBOutlet UITextField *emailInput;
@property (weak, nonatomic) IBOutlet UITextField *passwordInput;

@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (weak, nonatomic) IBOutlet UIButton *lostPwBtn;


@end
