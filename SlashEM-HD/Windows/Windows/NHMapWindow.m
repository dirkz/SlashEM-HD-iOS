//
//  NHMapWindow.m
//  UnNetHack
//
//  Created by Dirk Zimmermann on 5/18/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import "NHMapWindow.h"

#import "hack.h" // NHW_MAP, ROWNO, COLNO

const int NHMapWindowNoGlyph = -1;

@implementation NHMapWindow
{
    int _glyphs[ROWNO][COLNO];
}

@synthesize rows = _rows;
@synthesize cols = _cols;
@synthesize clipX = _clipX;
@synthesize clipY = _clipY;

- (id)init
{
    if ((self = [super initWithType:NHW_MAP])) {
        _rows = ROWNO;
        _cols = COLNO;
        [self clear];
    }
    return self;
}

- (void)cliparoundX:(int)x y:(int)y
{
    _clipX = x;
    _clipY = y;
}

- (void)setGlyph:(int)glyph atX:(int)x y:(int)y
{
    _glyphs[y][x] = glyph;
}

- (void)clear
{
    memset(_glyphs, NHMapWindowNoGlyph, sizeof(int) * _rows * _cols);
}

- (int)glyphAtX:(int)x y:(int)y
{
    return _glyphs[y][x];
}

@end
