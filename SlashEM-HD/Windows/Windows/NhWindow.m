//
//  NhWindow.m
//  UnNetHack
//
//  Created by Dirk Zimmermann on 5/18/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import "NhWindow.h"

@implementation NhWindow

@synthesize type;

- (id)initWithType:(int)t
{
    if ((self = [super init])) {
        type = t;
    }
    return self;
}

- (NSString *)typeName
{
    NSString *names[] = {
        @"NHW_MESSAGE",
        @"NHW_STATUS",
        @"NHW_MAP",
        @"NHW_MENU",
        @"NHW_TEXT",
    };
    return names[type-1];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ 0x%x>", self.typeName, self];
}

@end
