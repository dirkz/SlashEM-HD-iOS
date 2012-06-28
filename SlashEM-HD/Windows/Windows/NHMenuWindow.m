//
//  NHMenuWindow.m
//  UnNetHack
//
//  Created by Dirk Zimmermann on 5/18/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import "NHMenuWindow.h"

#import "NHMenuItem.h"

@interface NHMenuWindow ()

@property (nonatomic, readonly) NSMutableArray *lines;

@end

@implementation NHMenuWindow
{

    NSMutableArray *_groups;
    NSMutableDictionary *_groupsToItems;

}

@synthesize prompt = _prompt;
@synthesize groups = _groups;
@synthesize numberOfItemsSelected = _numberOfItemsSelected;
@synthesize menuStyle = _menuStyle;
@synthesize selected = _selected;
@synthesize lines = _lines;

- (id)init
{
    if ((self = [super initWithType:NHW_MENU])) {
        _groups = [[NSMutableArray alloc] init];
        _groupsToItems = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)reset
{
    [_groups removeAllObjects];
    [_groupsToItems removeAllObjects];
}

- (void)addGroupWithTitle:(NSString *)title accelerator:(char)accelerator
{
    [_groups addObject:title];
    NSMutableArray *items = [[NSMutableArray alloc] init];
    [_groupsToItems setObject:items forKey:title];
}

- (void)addTtemWithTitle:(NSString *)title glyph:(int)glyph identifier:(ANY_P)identifier
             accelerator:(char)accelerator attribute:(int)attribute preselected:(BOOL)preselected
{
    if (!identifier.a_int) {
        [self addGroupWithTitle:title accelerator:accelerator];
    } else {
        NHMenuItem *item = [[NHMenuItem alloc] initWithTitle:title glyph:glyph identifier:identifier
                                                 accelerator:accelerator attribute:attribute preselected:preselected];
        if (!self.groups.count) {
            [self addGroupWithTitle:@"All" accelerator:0];
        }
        NSString *groupTitle = [_groups lastObject];
        NSMutableArray *items = [_groupsToItems objectForKey:groupTitle];
        [items addObject:item];
    }
}

- (NSArray *)itemsForGroupNamed:(NSString *)title
{
    return [NSArray arrayWithArray:[_groupsToItems objectForKey:title]];
}

- (NSArray *)itemsAtGroupWithIndex:(NSUInteger)i
{
    return [_groupsToItems objectForKey:[_groups objectAtIndex:i]];
}

- (NSArray *)allItems
{
    NSMutableArray *allItems = [NSMutableArray array];
    NSUInteger count = self.groups.count;
    for (NSUInteger i = 0; i < count; ++i) {
        [allItems addObjectsFromArray:[self itemsAtGroupWithIndex:i]];
    }
    return [NSArray arrayWithArray:allItems];
}

- (NSArray *)allSelectedItems
{
    return [[self allItems] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"selected == YES"]];
}

- (NHMenuItem *)itemAtIndexPath:(NSIndexPath *)indexPath
{
    return [[self itemsAtGroupWithIndex:indexPath.section] objectAtIndex:indexPath.row];
}

#pragma mark - Properties

@end
