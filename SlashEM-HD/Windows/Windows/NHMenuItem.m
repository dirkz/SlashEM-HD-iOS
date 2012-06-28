//
//  NHMenuItem.m
//  SlashEM-HD
//
//  Created by Dirk Zimmermann on 6/21/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import "NHMenuItem.h"

@interface NHMenuItem ()

@property (nonatomic, readonly) NSRegularExpression *itemAmountRegularExpression;

@end

@implementation NHMenuItem

@synthesize titleWithoutAmount = _titleWithoutAmount;
@synthesize glyph = _glyph;
@synthesize identifier = _identifier;
@synthesize accelerator = _accelerator;
@synthesize attribute = _attribute;
@synthesize preselected = _preselected;
@synthesize selected = _selected;
@synthesize amount = _amount;
@synthesize itemAmountRegularExpression = _itemAmountRegularExpression;
@synthesize selectedAmount = _selectedAmount;

- (id)initWithTitle:(NSString *)title glyph:(int)glyph identifier:(ANY_P)identifier
        accelerator:(char)accelerator attribute:(int)attribute preselected:(BOOL)preselected
{
    self = [super init];
    if (self) {
        [self setTitleFromTitle:title];
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

/**
 * Determines amount and title from full title as given by NH.
 */
- (void)setTitleFromTitle:(NSString *)fullTitle
{
    NSRange rangeOfFirstMatch = [self.itemAmountRegularExpression
                                 rangeOfFirstMatchInString:fullTitle options:0 range:NSMakeRange(0, fullTitle.length)];
    if (!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0))) {
        NSString *substringForFirstMatch = [fullTitle substringWithRange:rangeOfFirstMatch];
        _amount = [substringForFirstMatch integerValue];
        _titleWithoutAmount = [fullTitle substringFromIndex:rangeOfFirstMatch.location + rangeOfFirstMatch.length];
    } else {
        _amount = 1;
        _titleWithoutAmount = [fullTitle copy];
    }
    _selectedAmount = _amount;
}

#pragma mark - Internal

/** @return Regex for determining item amount, from title, needed only once */
- (NSRegularExpression *)itemAmountRegularExpression
{
    if (!_itemAmountRegularExpression) {
        NSError *error = NULL;
        _itemAmountRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"^\\d+ "
                                                                                 options:NSRegularExpressionCaseInsensitive
                                                                                   error:&error];
        NSAssert1(!error, @"NSRegularExpression error: %@", error);
    }
    return _itemAmountRegularExpression;
}

#pragma mark - Properties

- (NSString *)title
{
    if (self.amount > 1) {
        return [NSString stringWithFormat:@"%d %@", self.selectedAmount, _titleWithoutAmount];
    } else {
        return _titleWithoutAmount;
    }
}

@end
