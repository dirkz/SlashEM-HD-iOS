//
//  NHMenuItem.m
//  SlashEM-HD
//
//  Created by Dirk Zimmermann on 6/21/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import "NHMenuItem.h"

@implementation NHMenuItem

@synthesize title = _title;
@synthesize glyph = _glyph;
@synthesize identifier = _identifier;
@synthesize accelerator = _accelerator;
@synthesize attribute = _attribute;
@synthesize preselected = _preselected;
@synthesize selected = _selected;

- (id)initWithTitle:(NSString *)title glyph:(int)glyph identifier:(ANY_P)identifier
        accelerator:(char)accelerator attribute:(int)attribute preselected:(BOOL)preselected
{
    self = [super init];
    if (self) {
        _title = title;
        _glyph = glyph;
        _identifier = identifier;
        _accelerator = accelerator;
        _attribute = attribute;
        _preselected = preselected;
        if (_preselected) {
            _selected = YES;
        }
    }
    return self;
}

@end
