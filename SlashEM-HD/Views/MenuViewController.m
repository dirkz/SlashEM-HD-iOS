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

@interface MenuViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *okButton;

@end

@implementation MenuViewController

@synthesize okButton = _okButton;
@synthesize menuWindow = _menuWindow;
@synthesize delegate = _delegate;

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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MenuViewCell"];

    NHMenuItem *item = [self.menuWindow itemAtIndexPath:indexPath];
    cell.textLabel.text = [self titleForMenuItem:item];
    if (self.menuWindow.menuStyle == PICK_ANY) {
        cell.accessoryType = item.selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }

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

- (IBAction)cancelAction:(id)sender
{
    [self.delegate menuViewController:self cancelMenuWindow:self.menuWindow];
}

- (IBAction)okAction:(id)sender
{
    [self.delegate menuViewController:self pickAnyItems:[self.menuWindow allSelectedItems] menuWindow:self.menuWindow];
}

@end
