//
//  NHMenuWindow.m
//  UnNetHack
//
//  Created by Dirk Zimmermann on 5/18/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import "NHMenuWindow.h"

#import "NHMenuItem.h"

@implementation NHMenuWindow
{

    NSMutableArray *groupTitles;
    NSMutableDictionary *groups;

}

@synthesize prompt;
@synthesize groupTitles;
@synthesize numberOfItemsSelected;
@synthesize menuStyle = _menuStyle;
@synthesize selected = _selected;

- (id)init
{
    if ((self = [super initWithType:NHW_MENU])) {
        groupTitles = [[NSMutableArray alloc] init];
        groups = [[NSMutableDictionary alloc] init];
    }
    return self;
}


- (void)reset
{
    [groupTitles removeAllObjects];
    [groups removeAllObjects];
}

- (void)addGroupWithTitle:(NSString *)title accelerator:(char)accelerator
{
    [groupTitles addObject:title];
    NSMutableArray *items = [[NSMutableArray alloc] init];
    [groups setObject:items forKey:title];
}

- (void)addTtemWithTitle:(NSString *)title glyph:(int)glyph identifier:(ANY_P)identifier
             accelerator:(char)accelerator attribute:(int)attribute preselected:(BOOL)preselected
{
    NHMenuItem *item = [[NHMenuItem alloc] initWithTitle:title glyph:glyph identifier:identifier
                                             accelerator:accelerator attribute:attribute preselected:preselected];
    if (!groupTitles.count) {
        [self addGroupWithTitle:@"All" accelerator:0];
    }
    NSString *groupTitle = [groupTitles lastObject];
    NSMutableArray *items = [groups objectForKey:groupTitle];
    [items addObject:item];
}

- (NSArray *)itemsForGroupWithTitle:(NSString *)title
{
    return [NSArray arrayWithArray:[groups objectForKey:title]];
}

- (NSArray *)itemsAtIndex:(NSUInteger)i
{
    return [groups objectForKey:[groupTitles objectAtIndex:i]];
}

- (NHMenuItem *)itemAtIndexPath:(NSIndexPath *)indexPath
{
    return [[self itemsAtIndex:indexPath.section] objectAtIndex:indexPath.row];
}

#pragma mark - Properties

- (NSUInteger)groupCount
{
    return groups.count;
}

@end
