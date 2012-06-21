//
//  StatusWindow.h
//  UnNetHack
//
//  Created by Dirk Zimmermann on 5/18/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import "NhWindow.h"

@interface StatusWindow : NhWindow

- (void)setCursorX:(int)x y:(int)y;
- (void)putString:(NSString *)string withAttribute:(int)attr;

@end
