//
//  MenuViewController.m
//  SlashEM-HD
//
//  Created by Dirk Zimmermann on 6/21/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import "MenuViewController.h"

#import "NHMenuItem.h"
#import "NSLogger.h"
#import "ItemWithAmountTableViewCellCell.h"

@interface MenuViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *okButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MenuViewController
{
    NSMutableDictionary *_sliders;
}

@synthesize okButton = _okButton;
@synthesize tableView = _tableView;
@synthesize menuWindow = _menuWindow;
@synthesize delegate = _delegate;

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _sliders = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [self setOkButton:nil];
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    if (self.menuWindow.menuStyle == PICK_ANY) {
        self.okButton.enabled = YES;
    } else {
        self.okButton.enabled = NO;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Util

- (NSString *)titleForMenuItem:(NHMenuItem *)item
{
    if (item.accelerator) {
        return [NSString stringWithFormat:@"%c - %@", item.accelerator, item.title];
    } else {
        return item.title;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.menuWindow.groups.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.menuWindow itemsAtGroupWithIndex:section].count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[self.menuWindow groups] objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NHMenuItem *item = [self.menuWindow itemAtIndexPath:indexPath];

    UITableViewCell *cell = nil;
    if (self.menuWindow.menuStyle == PICK_NONE) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"StandardMenuViewCell"];
    } else {
        if (item.amount > 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SliderMenuViewCell"];
            UISlider *slider = [(ItemWithAmountTableViewCellCell *) cell amountSlider];
            slider.minimumValue = 1;
            slider.maximumValue = item.amount;
            slider.value = item.amount;
            slider.continuous = YES;
            [slider addTarget:self action:@selector(sliderAmountChanged:) forControlEvents:UIControlEventValueChanged];
            [_sliders setObject:indexPath forKey:[NSValue valueWithPointer:(__bridge void *) slider]];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"StandardMenuViewCell"];
        }

        if (self.menuWindow.menuStyle == PICK_ANY) {
            cell.accessoryType = item.selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        }
    }

    cell.textLabel.text = [self titleForMenuItem:item];

    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LOG_VIEW(1, @"indexPath %@", indexPath);
    if (self.menuWindow.menuStyle == PICK_NONE) {
        [self.delegate menuViewController:self pickNoneMenuWindow:self.menuWindow];
    } else if (self.menuWindow.menuStyle == PICK_ONE) {
        NHMenuItem *item = [self.menuWindow itemAtIndexPath:indexPath];
        [self.delegate menuViewController:self pickOneItem:item menuWindow:self.menuWindow];
    } else if (self.menuWindow.menuStyle == PICK_ANY) {
        NHMenuItem *item = [self.menuWindow itemAtIndexPath:indexPath];
        item.selected = !item.selected;
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = item.selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat static standardHeight = 45.f; // should match the actual height for the cell in storyboard
    CGFloat static standardHeightPlusAmount = 68.f; // should match the actual height for the cell in storyboard
    NHMenuItem *item = [self.menuWindow itemAtIndexPath:indexPath];
    if (self.menuWindow.menuStyle == PICK_NONE) {
        return standardHeight;
    } else if (item.amount > 1) {
        return standardHeightPlusAmount;
    } else {
        return standardHeight;
    }
}

- (IBAction)cancelAction:(id)sender
{
    [self.delegate menuViewController:self cancelMenuWindow:self.menuWindow];
}

- (IBAction)okAction:(id)sender
{
    [self.delegate menuViewController:self pickAnyItems:[self.menuWindow allSelectedItems] menuWindow:self.menuWindow];
}

#pragma mark - UISlider Target

- (void)sliderAmountChanged:(UISlider *)slider
{
    NSIndexPath *indexPath = [_sliders objectForKey:[NSValue valueWithPointer:(__bridge void*) slider]];
    LOG_VIEW(1, @"slider value %f indexPath %@", slider.value, indexPath);
    NHMenuItem *item = [self.menuWindow itemAtIndexPath:indexPath];
    item.selectedAmount = slider.value;
    ItemWithAmountTableViewCellCell *cell = (ItemWithAmountTableViewCellCell *) [self.tableView
                                                                                 cellForRowAtIndexPath:indexPath];
    cell.textLabel.text = [self titleForMenuItem:item];
    if (self.menuWindow.menuStyle == PICK_ANY) {
        cell.accessoryType = item.selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }

    if (self.menuWindow.menuStyle == PICK_ANY) {
        item.selected = YES;
    }
}

@end
