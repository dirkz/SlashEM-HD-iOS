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

@interface SlashEMViewController : UIViewController <WiniOSDelegate, UITextFieldDelegate,MenuViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UITextField *inputTextField;

@end
