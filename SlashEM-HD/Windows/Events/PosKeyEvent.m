//
//  PosKeyEvent.m
//  UnNetHack
//
//  Created by Dirk Zimmermann on 5/18/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import "PosKeyEvent.h"

@implementation PosKeyEvent

@synthesize x;
@synthesize y;
@synthesize mod;

+ (id)eventWithKey:(char)k x:(int)anX y:(int)anY mod:(int)aMod
{
    return [[self alloc] initWithKey:k x:anX y:anY mod:aMod];
}

- (id)initWithKey:(char)k x:(int)anX y:(int)anY mod:(int)aMod
{
    if ((self = [super initWithKey:k])) {
        x = anX;
        y = anY;
        mod = aMod;
    }
    return self;
}


@end
