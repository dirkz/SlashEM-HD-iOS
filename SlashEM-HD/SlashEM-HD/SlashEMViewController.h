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
#import "MapViewDelegate.h"

@interface SlashEMViewController : UIViewController <WiniOSDelegate, UITextFieldDelegate,MenuViewControllerDelegate,
MessageViewControllerDelegate, MapViewDelegate>

@end
