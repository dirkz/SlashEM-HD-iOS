//
//  StatusWindow.h
//  UnNetHack
//
//  Created by Dirk Zimmermann on 5/18/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import "NHWindow.h"

@interface NHStatusWindow : NHWindow

@property (nonatomic, assign) int cursorX;
@property (nonatomic, assign) int cursorY;

- (void)setCursorX:(int)x y:(int)y;

@end
