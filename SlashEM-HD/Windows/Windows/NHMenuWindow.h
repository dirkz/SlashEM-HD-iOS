//
//  NHMenuWindow.h
//  UnNetHack
//
//  Created by Dirk Zimmermann on 5/18/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NhWindow.h"

#import "hack.h" // NHW_MENU, ANY_P

@class NHMenuItem;

@interface NHMenuWindow : NHWindow

@property (nonatomic, copy) NSString *prompt;
@property (nonatomic, readonly) NSArray *groups;
@property (nonatomic, assign) NSInteger numberOfItemsSelected;
@property (nonatomic) int menuStyle; // 'how': PICK_NONE, PICK_ONE or PICK_ANY
@property (nonatomic) menu_item **selected;

/** @return If putString was used, all lines as newline-separated string */
@property (nonatomic, readonly) NSString *text;

- (void)reset;
- (void)addGroupWithTitle:(NSString *)title accelerator:(char)accelerator;
- (void)addTtemWithTitle:(NSString *)title glyph:(int)glyph identifier:(ANY_P)identifier
             accelerator:(char)accelerator attribute:(int)attribute preselected:(BOOL)preselected;
- (NSArray *)itemsForGroupNamed:(NSString *)groupTitle;
- (NSArray *)itemsAtGroupWithIndex:(NSUInteger)i;

/** @return Array of all items in all groups */
- (NSArray *)allItems;

/** @return Array of all selected items in all groups */
- (NSArray *)allSelectedItems;

/** @return Item # indexPath.row at group indexPath.section */
- (NHMenuItem *)itemAtIndexPath:(NSIndexPath *)indexPath;

/** Some NH routines use NHWindow for displaying text */
- (void)putString:(NSString *)string;

@end
