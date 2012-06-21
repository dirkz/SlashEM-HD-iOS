//
//  NHMapWindow.h
//  UnNetHack
//
//  Created by Dirk Zimmermann on 5/18/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NHWindow.h"

@interface NHMapWindow : NHWindow

@property (nonatomic, assign) int clipX;
@property (nonatomic, assign) int clipY;

- (void)cliparoundX:(int)x y:(int)y;
- (void)clear;
- (void)setGlyph:(int)glyph atX:(int)x y:(int)y;

@end
