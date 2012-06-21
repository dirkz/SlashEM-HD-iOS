//
//  MapWindow.m
//  UnNetHack
//
//  Created by Dirk Zimmermann on 5/18/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import "MapWindow.h"

#import "hack.h" // NHW_MAP, ROWNO, COLNO

@implementation MapWindow
{
    int glyphs[ROWNO][COLNO];
}

@synthesize clipX;
@synthesize clipY;

- (id)init
{
    if ((self = [super initWithType:NHW_MAP])) {
    }
    return self;
}

- (void)cliparoundX:(int)x y:(int)y
{
    clipX = x;
    clipY = y;
}

- (void)setGlyph:(int)glyph atX:(int)x y:(int)y
{
    glyphs[y][x] = glyph;
}

- (void)clear
{
    memset(glyphs, ROWNO * COLNO, sizeof(int));
}

@end
