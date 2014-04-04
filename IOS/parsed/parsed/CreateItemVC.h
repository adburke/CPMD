//
//  CreateItemVC.h
//  parsed
//
//  Created by Aaron Burke on 4/3/14.
//  Copyright (c) 2014 Aaron Burke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateItemVC : UIViewController <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameInput;
@property (weak, nonatomic) IBOutlet UITextField *messageInput;
@property (weak, nonatomic) IBOutlet UITextField *randomNumInput;

@property (weak, nonatomic) IBOutlet UILabel *greyBg;
@property (weak, nonatomic) IBOutlet UILabel *whiteBg;

@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *createDataBtn;


@end
