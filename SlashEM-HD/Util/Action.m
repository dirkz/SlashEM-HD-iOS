//
//  Action.m
//  SlashEM-HD
//
//  Created by Dirk Zimmermann on 7/2/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import "Action.h"

@implementation Action
{
    void (^_block)(Action *action, id context);
}

@synthesize title = _title;
@synthesize context = _context;

+ (id)actionWithTitle:(NSString *)title context:(id)context block:(void (^)(Action *action, id context))block
{
    return [[self alloc] initWithTitle:title context:context block:block];
}

- (id)initWithTitle:(NSString *)title context:(id)context block:(void (^)(Action *action, id context))block;
{
    self = [super init];
    if (self) {
        _title = [title copy];
        _context = context;
        _block = [block copy];
    }
    return self;
}


- (void)invoke
{
    _block(self, self.context);
}

@end
