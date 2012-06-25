//
//  NHMapWindow.h
//  UnNetHack
//
//  Created by Dirk Zimmermann on 5/18/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NHWindow.h"

extern const int NHMapWindowNoGlyph;

@interface NHMapWindow : NHWindow

@property (nonatomic, assign) int rows;
@property (nonatomic, assign) int cols;
@property (nonatomic, assign) int clipX;
@property (nonatomic, assign) int clipY;

- (void)cliparoundX:(int)x y:(int)y;
- (void)clear;
- (void)setGlyph:(int)glyph atX:(int)x y:(int)y;
- (int)glyphAtX:(int)x y:(int)y;

@end
