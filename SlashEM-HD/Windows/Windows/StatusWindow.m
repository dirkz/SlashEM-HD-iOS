//
//  StatusWindow.m
//  UnNetHack
//
//  Created by Dirk Zimmermann on 5/18/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import "StatusWindow.h"

#import "hack.h" // NHW_STATUS

@implementation StatusWindow
{
    int cursorX;
    int cursorY;
}

- (id)init
{
    if ((self = [super initWithType:NHW_STATUS])) {
    }
    return self;
}

- (void)setCursorX:(int)x y:(int)y
{
    cursorX = x;
    cursorY = y;
}

- (void)putString:(NSString *)string withAttribute:(int)attr
{
    
}

@end
