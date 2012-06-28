//
//  NHMenuItem.h
//  SlashEM-HD
//
//  Created by Dirk Zimmermann on 6/21/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "hack.h" // ANY_P

@interface NHMenuItem : NSObject

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *titleWithoutAmount;
@property (nonatomic, readonly) int glyph;
@property (nonatomic, readonly) ANY_P identifier;
@property (nonatomic, readonly) char accelerator;
@property (nonatomic, readonly) int attribute;
@property (nonatomic, readonly) BOOL preselected;
@property (nonatomic, assign) BOOL selected;

/** Original amount for this item */
@property (nonatomic, readonly) NSUInteger amount;

/** Amount chosen by the user */
@property (nonatomic, assign) NSUInteger selectedAmount;

- (id)initWithTitle:(NSString *)title glyph:(int)glyph identifier:(ANY_P)identifier
        accelerator:(char)accelerator attribute:(int)attribute preselected:(BOOL)preselected;

@end
