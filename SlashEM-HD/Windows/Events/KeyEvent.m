//
//  KeyEvent.m
//  UnNetHack
//
//  Created by Dirk Zimmermann on 5/17/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import "KeyEvent.h"

@implementation KeyEvent

@synthesize key;

+ (id)eventWithKey:(char)k
{
    return [[self alloc] initWithKey:k];
}

- (id)initWithKey:(char)k
{
    if ((self = [super init])) {
        key = k;
    }
    return self;
}

@end
