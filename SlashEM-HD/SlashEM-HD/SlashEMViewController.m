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
#import "NHMenuItem.h"

typedef enum {
    UIStateUndefined,
    UIStateYNQuestion,
    UIStatePoskey,
} UITextInputState;

NSString * const NetHackMessageMenuWindowSegue = @"NetHackMessageMenuWindowSegue";
NSString * const NetHackMenuViewSegue = @"NetHackMenuViewSegue";

@interface SlashEMViewController ()

@property (nonatomic, strong) YNQuestionData *ynQuestionData;
@property (nonatomic, strong) NHMenuWindow *menuWindow;
@property (nonatomic, assign) UITextInputState state;

@end

@implementation SlashEMViewController
{

    WiniOS *winios;
    Queue *events;
    UIViewController *displayedViewController;

}

@synthesize messageTextView;
@synthesize inputTextField;
@synthesize statusLabel1;
@synthesize statusLabel2;
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
    [self setStatusLabel1:nil];
    [self setStatusLabel2:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification object:nil];

    winios.delegate = self;
    [winios start];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
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
    self.menuWindow = window;
    [self performSegueWithIdentifier:NetHackMenuViewSegue sender:nil];
}

- (void)handleMessageMenuWindow:(NHMenuWindow *)window
{
    self.menuWindow = window;
    [self performSegueWithIdentifier:NetHackMessageMenuWindowSegue sender:nil];
}

- (void)setStatusString:(NSString *)string line:(NSUInteger)i
{
    if (i == 0) {
        [statusLabel1 setText:string];
    } else {
        [statusLabel2 setText:string];
    }
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    LOG_VIEW(1, @"segue %@", segue.identifier);
    if ([segue.identifier isEqualToString:NetHackMenuViewSegue]) {
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
    } else if ([segue.identifier isEqualToString:NetHackMessageMenuWindowSegue]) {
        MessageViewController *vc = segue.destinationViewController;
        vc.menuWindow = self.menuWindow;
        vc.delegate = self;
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
    [events enterObject:WiniOSMenuFinishedEvent];
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

#pragma mark - MessageViewControllerDelegate

- (void)menuViewController:(MessageViewController *)viewController doneButtonForMenuWindow:(NHMenuWindow *)window
{
    [viewController dismissModalViewControllerAnimated:NO];
    [events enterObject:WiniOSMessageDisplayFinishedEvent];
}

#pragma mark - show/hide Keyboard

- (void)keyboardDidShow:(NSNotification *)aNotification
{
    CGRect keyboardFrame = [[aNotification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardFrame = [self.view convertRect:keyboardFrame fromView:nil];
    CGSize keyboardSize = keyboardFrame.size;

    CGRect statusFrame = self.statusLabel1.frame;
    statusFrame.origin.y -= keyboardSize.height;
    self.statusLabel1.frame = statusFrame;

    statusFrame = self.statusLabel2.frame;
    statusFrame.origin.y -= keyboardSize.height;
    self.statusLabel2.frame = statusFrame;
}

- (void)keyboardDidHide:(NSNotification *)aNotification
{
    CGRect keyboardFrame = [[aNotification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardFrame = [self.view convertRect:keyboardFrame fromView:nil];
    CGSize keyboardSize = keyboardFrame.size;

    CGRect statusFrame = self.statusLabel1.frame;
    statusFrame.origin.y += keyboardSize.height;
    self.statusLabel1.frame = statusFrame;

    statusFrame = self.statusLabel2.frame;
    statusFrame.origin.y += keyboardSize.height;
    self.statusLabel2.frame = statusFrame;
}

@end
