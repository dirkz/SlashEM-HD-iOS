//
//  StatusWindow.m
//  UnNetHack
//
//  Created by Dirk Zimmermann on 5/18/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import "NHStatusWindow.h"

#import "hack.h" // NHW_STATUS

#import "NSLogger.h"

@implementation NHStatusWindow

@synthesize cursorX = _cursorX;
@synthesize cursorY = _cursorY;

- (id)init
{
    if ((self = [super initWithType:NHW_STATUS])) {
    }
    return self;
}

- (void)setCursorX:(int)x y:(int)y
{
    self.cursorX = x;
    self.cursorY = y;
}

@end
