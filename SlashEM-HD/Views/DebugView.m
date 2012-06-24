//
//  DebugView.m
//  SlashEM-HD
//
//  Created by Dirk Zimmermann on 6/24/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import "DebugView.h"

#import "NSLogger.h"

@implementation DebugView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setFrame:(CGRect)frame
{
    LOG_VIEW(1, @"setFrame %@ -> %@", NSStringFromCGRect(self.frame), NSStringFromCGRect(frame));
    [super setFrame:frame];
}

- (void)setBounds:(CGRect)bounds
{
    LOG_VIEW(1, @"setBounds %@ -> %@", NSStringFromCGRect(self.bounds), NSStringFromCGRect(bounds));
    [super setBounds:bounds];
}

- (void)setCenter:(CGPoint)center
{
    LOG_VIEW(1, @"setCenter %@ -> %@", NSStringFromCGPoint(self.center), NSStringFromCGPoint(center));
    [super setCenter:center];
}

@end
