//
//  PosKeyEvent.h
//  UnNetHack
//
//  Created by Dirk Zimmermann on 5/18/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KeyEvent.h"

@interface PosKeyEvent : KeyEvent;

@property (nonatomic, readonly) int x;
@property (nonatomic, readonly) int y;
@property (nonatomic, readonly) int mod;

+ (id)eventWithKey:(char)k x:(int)anX y:(int)anY mod:(int)aMod;

- (id)initWithKey:(char)k x:(int)anX y:(int)anY mod:(int)aMod;

@end
