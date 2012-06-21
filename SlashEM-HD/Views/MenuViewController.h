//
//  MenuViewController.h
//  SlashEM-HD
//
//  Created by Dirk Zimmermann on 6/21/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NHMenuWindow.h"

@class MenuViewController;

@protocol MenuViewControllerDelegate

- (void)menuViewController:(MenuViewController *)viewController cancelMenuWindow:(NHMenuWindow *)window;
- (void)menuViewController:(MenuViewController *)viewController pickNoneMenuWindow:(NHMenuWindow *)window;
- (void)menuViewController:(MenuViewController *)viewController pickOneItem:(NHMenuItem *)item
                menuWindow:(NHMenuWindow *)window;

@end

@interface MenuViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NHMenuWindow *menuWindow;
@property (nonatomic, weak) id<MenuViewControllerDelegate> delegate;

- (IBAction)cancelAction:(id)sender;

@end
