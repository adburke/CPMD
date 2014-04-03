//
//  RegisterVC.h
//  parsed
//
//  Created by Aaron Burke on 4/2/14.
//  Copyright (c) 2014 Aaron Burke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterVC : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *registerBg;
@property (weak, nonatomic) IBOutlet UITextField *passwordInput;
@property (weak, nonatomic) IBOutlet UITextField *confirmPassInput;
@property (weak, nonatomic) IBOutlet UITextField *emailInput;

@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;


@end
