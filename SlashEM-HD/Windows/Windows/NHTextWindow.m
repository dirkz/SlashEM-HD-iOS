//
//  NHTextWindow.m
//  SlashEM-HD
//
//  Created by Dirk Zimmermann on 6/28/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import "NHTextWindow.h"

#import "hack.h"

@interface NHTextWindow ()

@property (nonatomic, readonly) NSMutableArray *lines;

@end

@implementation NHTextWindow

@synthesize lines = _lines;

- (id)init
{
    if ((self = [super initWithType:NHW_TEXT])) {
    }
    return self;
}

- (void)putString:(NSString *)string
{
    [self.lines addObject:string];
}

- (NSMutableArray *)lines
{
    if (!_lines) {
        _lines = [[NSMutableArray alloc] init];
    }
    return _lines;
}

- (NSString *)text
{
    return [self.lines componentsJoinedByString:@"\n"];
}

@end
