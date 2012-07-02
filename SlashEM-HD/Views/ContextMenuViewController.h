//
//  ContextMenuViewController.h
//  SlashEM-HD
//
//  Created by Dirk Zimmermann on 7/2/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContextMenuViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

/** Array of Action */
@property (nonatomic, retain) NSArray *actions;

@end
