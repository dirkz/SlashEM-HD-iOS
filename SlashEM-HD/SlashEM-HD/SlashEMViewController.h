//
//  SlashEMViewController.h
//  SlashEM-HD
//
//  Created by Dirk Zimmermann on 6/21/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WiniOS.h"

#import "MenuViewController.h"
#import "MessageViewController.h"

@interface SlashEMViewController : UIViewController <WiniOSDelegate, UITextFieldDelegate,MenuViewControllerDelegate,
MessageViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UITextField *inputTextField;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel1;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel2;

@end
