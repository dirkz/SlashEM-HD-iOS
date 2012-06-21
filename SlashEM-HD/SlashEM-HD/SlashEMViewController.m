//
//  SlashEMViewController.m
//  SlashEM-HD
//
//  Created by Dirk Zimmermann on 6/21/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import "SlashEMViewController.h"

#import "NSLogger.h"

#import "YNQuestionData.h"
#import "Queue.h"
#import "KeyEvent.h"
#import "PosKeyEvent.h"
#import "NHMenuWindow.h"
#import "MenuFinishedEvent.h"
#import "MenuFinishedEvent.h"
#import "NHMenuItem.h"

typedef enum {
    UIStateUndefined,
    UIStateYNQuestion,
    UIStatePoskey,
    UIStateMenu,
} UIState;

@interface SlashEMViewController ()

@property (nonatomic, strong) YNQuestionData *ynQuestionData;
@property (nonatomic, strong) NHMenuWindow *menuWindow;
@property (nonatomic, assign) UIState state;

@end

@implementation SlashEMViewController
{

    WiniOS *winios;
    Queue *events;
    UIViewController *displayedViewController;

}

@synthesize messageTextView;
@synthesize inputTextField;
@synthesize ynQuestionData = _ynQuestionData;
@synthesize menuWindow = _menuWindow;
@synthesize state = _state;

- (void)viewDidLoad
{
    [super viewDidLoad];
    inputTextField.frame = CGRectZero;    
    winios = [[WiniOS alloc] init];
}

- (void)viewDidUnload
{
    [self setMessageTextView:nil];
    [self setInputTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
    winios.delegate = self;
    [winios start];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - WiniOSDelegate

- (void)setEventQueue:(Queue *)eventQueue
{
    events = eventQueue;
}

- (void)handleYNQuestion:(YNQuestionData *)question
{
    self.ynQuestionData = question;
    [inputTextField becomeFirstResponder];
}

- (void)handlePutstr:(NSString *)message attribute:(int)attr
{
    if (message.length > 0) {
        if (messageTextView.hasText) {
            messageTextView.text = [NSString stringWithFormat:@"%@ %@", messageTextView.text, message];
        } else {
            messageTextView.text = message;
        }
        [messageTextView scrollRangeToVisible:NSMakeRange(messageTextView.text.length-1, 1)];
    }
}

- (void)handlePoskey
{
    self.state = UIStatePoskey;
    [inputTextField becomeFirstResponder];
}

- (void)handleClearMessages
{
    messageTextView.text = @"";
}

- (void)handleMenuWindow:(NHMenuWindow *)window
{
    self.state = UIStateMenu;
    self.menuWindow = window;
    [self performSegueWithIdentifier:@"MenuViewSegue" sender:nil];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    LOG_VIEW(1, @"segue %@", segue.identifier);
    if ([@"MenuViewSegue" isEqualToString:segue.identifier]) {
        LOG_VIEW(1, @"segue %@ %@", segue.identifier, segue.destinationViewController);
        displayedViewController = segue.destinationViewController;
        MenuViewController *menuViewController = nil;
        if ([displayedViewController isKindOfClass:[UINavigationController class]]) {
            displayedViewController = [(UINavigationController *) displayedViewController visibleViewController];
            menuViewController = (MenuViewController *) displayedViewController;
        } else {
            menuViewController = segue.destinationViewController;
        }
        menuViewController.delegate = self;
        menuViewController.menuWindow = self.menuWindow;
        if (self.menuWindow.prompt) {
            menuViewController.title = self.menuWindow.prompt;
        }
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string
{
    if (string.length > 0) {
        unichar ch = [string characterAtIndex:0];
        switch (self.state) {
            case UIStateYNQuestion: {
                KeyEvent *event = [KeyEvent eventWithKey:ch];
                [events enterObject:event];
                self.ynQuestionData = nil;
            }
                break;
            case UIStatePoskey: {
                PosKeyEvent *event = [PosKeyEvent eventWithKey:ch];
                [events enterObject:event];
                self.state = UIStateUndefined;
            }
                break;
                
            default:
                break;
        }
        [inputTextField resignFirstResponder];
    }
    return NO;
}

#pragma mark - Properties

- (void)setYnQuestionData:(YNQuestionData *)yn
{
    if (yn) {
        self.state = UIStateYNQuestion;
    } else {
        self.state = UIStateUndefined;
    }
    _ynQuestionData = yn;
}

#pragma mark - Util

- (void)dismissDisplayedViewController
{
    [displayedViewController dismissModalViewControllerAnimated:NO];
    displayedViewController = nil;
    MenuFinishedEvent *event = [MenuFinishedEvent event];
    [events enterObject:event];
}

#pragma mark - MenuViewControllerDelegate

- (void)menuViewController:(MenuViewController *)viewController cancelMenuWindow:(NHMenuWindow *)window
{
    self.menuWindow.numberOfItemsSelected = -1;
    [self dismissDisplayedViewController];
}

- (void)menuViewController:(MenuViewController *)viewController pickNoneMenuWindow:(NHMenuWindow *)window
{
    self.menuWindow.numberOfItemsSelected = -1;
    [self dismissDisplayedViewController];
}

- (void)menuViewController:(MenuViewController *)viewController pickOneItem:(NHMenuItem *)item
                menuWindow:(NHMenuWindow *)window
{
    *self.menuWindow.selected = malloc(sizeof(menu_item));
    (*self.menuWindow.selected)->count = 1;
    (*self.menuWindow.selected)->item.a_int = item.identifier.a_int;
    self.menuWindow.numberOfItemsSelected = 1;
    [self dismissDisplayedViewController];
}

@end
