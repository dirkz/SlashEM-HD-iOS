//
//  MessageViewController.m
//  SlashEM-HD
//
//  Created by Dirk Zimmermann on 6/24/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import "MessageViewController.h"

#import "NHMenuWindow.h"

@interface MessageViewController ()

@end

@implementation MessageViewController
{
    __weak IBOutlet UITextView *textView;
}

@synthesize delegate;
@synthesize menuWindow;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    textView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    textView.text = self.menuWindow.text;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)doneAction:(id)sender
{
    [self.delegate menuViewController:self doneButtonForMenuWindow:self.menuWindow];
}

@end
