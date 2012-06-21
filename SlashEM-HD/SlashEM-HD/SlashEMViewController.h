//
//  SlashEMViewController.h
//  SlashEM-HD
//
//  Created by Dirk Zimmermann on 6/21/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WiniOS.h"

@interface SlashEMViewController : UIViewController <WiniOSDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UITextField *inputTextField;

@end
