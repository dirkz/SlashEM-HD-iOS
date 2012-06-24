//
//  MessageViewController.h
//  SlashEM-HD
//
//  Created by Dirk Zimmermann on 6/24/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MessageViewController;
@class NHMenuWindow;

@protocol MessageViewControllerDelegate

- (void)menuViewController:(MessageViewController *)viewController doneButtonForMenuWindow:(NHMenuWindow *)window;

@end

@interface MessageViewController : UIViewController

@property (nonatomic, weak) id<MessageViewControllerDelegate> delegate;
@property (nonatomic, retain) NHMenuWindow *menuWindow;

@end
