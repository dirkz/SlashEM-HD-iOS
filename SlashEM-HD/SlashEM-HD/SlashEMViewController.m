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
#import "MapView.h"

typedef enum {
    UIStateUndefined,
    UIStateYNQuestion,
    UIStatePoskey,
} UITextInputState;

NSString * const NetHackMessageMenuWindowSegue = @"NetHackMessageMenuWindowSegue";
NSString * const NetHackMenuViewSegue = @"NetHackMenuViewSegue";

@interface SlashEMViewController ()

@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UITextField *inputTextField;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel1;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel2;
@property (weak, nonatomic) IBOutlet MapView *mapView;

@property (nonatomic, strong) YNQuestionData *ynQuestionData;
@property (nonatomic, strong) NHMenuWindow *menuWindow;
@property (nonatomic, assign) UITextInputState state;

@end

@implementation SlashEMViewController
{

    WiniOS *_winios;
    Queue *_events;
    UIViewController *_displayedViewController;

}

@synthesize messageTextView = _messageTextView;
@synthesize inputTextField = _inputTextField;
@synthesize statusLabel1 = _statusLabel1;
@synthesize statusLabel2 = _statusLabel2;
@synthesize mapView = _mapView;
@synthesize ynQuestionData = _ynQuestionData;
@synthesize menuWindow = _menuWindow;
@synthesize state = _state;

- (void)viewDidLoad
{
    [super viewDidLoad];
    _inputTextField.frame = CGRectZero;
    _winios = [[WiniOS alloc] init];
}

- (void)viewDidUnload
{
    [self setMessageTextView:nil];
    [self setInputTextField:nil];
    [self setStatusLabel1:nil];
    [self setStatusLabel2:nil];
    [self setMapView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification object:nil];

    _winios.delegate = self;
    [_winios start];
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
    _events = eventQueue;
}

- (void)handleYNQuestion:(YNQuestionData *)question
{
    self.ynQuestionData = question;
    [_inputTextField becomeFirstResponder];
}

- (void)handlePutstr:(NSString *)message attribute:(int)attr
{
    if (message.length > 0) {
        if (_messageTextView.hasText) {
            _messageTextView.text = [NSString stringWithFormat:@"%@ %@", _messageTextView.text, message];
        } else {
            _messageTextView.text = message;
        }
        [_messageTextView scrollRangeToVisible:NSMakeRange(_messageTextView.text.length-1, 1)];
    }
}

- (void)handlePoskey
{
    self.state = UIStatePoskey;
    [_inputTextField becomeFirstResponder];
}

- (void)handleClearMessages
{
    _messageTextView.text = @"";
}

- (void)handleMenuWindow:(NHMenuWindow *)window
{
    self.menuWindow = window;
    [self performSegueWithIdentifier:NetHackMenuViewSegue sender:nil];
}

- (void)setStatusString:(NSString *)string line:(NSUInteger)i
{
    if (i == 0) {
        [_statusLabel1 setText:string];
    } else {
        [_statusLabel2 setText:string];
    }
}

- (void)handleMessageMenuWindow:(NHMenuWindow *)window
{
    self.menuWindow = window;
    [self performSegueWithIdentifier:NetHackMessageMenuWindowSegue sender:nil];
}

- (void)handleMapDisplay:(NHMapWindow *)window block:(BOOL)block
{
    [self.mapView displayMapWindow:window];
    if (block) {
        LOG_VIEW(1, @"should block map display");
    }
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    LOG_VIEW(1, @"segue %@", segue.identifier);
    if ([segue.identifier isEqualToString:NetHackMenuViewSegue]) {
        _displayedViewController = segue.destinationViewController;
        MenuViewController *menuViewController = nil;
        if ([_displayedViewController isKindOfClass:[UINavigationController class]]) {
            _displayedViewController = [(UINavigationController *) _displayedViewController visibleViewController];
            menuViewController = (MenuViewController *) _displayedViewController;
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
                [_events enterObject:event];
                self.ynQuestionData = nil;
            }
                break;
            case UIStatePoskey: {
                PosKeyEvent *event = [PosKeyEvent eventWithKey:ch];
                [_events enterObject:event];
                self.state = UIStateUndefined;
            }
                break;

            default:
                break;
        }
        [_inputTextField resignFirstResponder];
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
    [_displayedViewController dismissModalViewControllerAnimated:NO];
    _displayedViewController = nil;
    [_events enterObject:WiniOSMenuFinishedEvent];
}

/** param keyboardFrame Keyboard frame in view coordinates */
- (void)layoutViewsWithKeyboardFrame:(CGRect)keyboardFrame
{
    CGRect messageFrame = _messageTextView.frame;
    CGRect statusFrame1 = self.statusLabel1.frame;
    CGRect statusFrame2 = self.statusLabel2.frame;

    CGRect mapFrame = _mapView.frame;
    mapFrame.origin.y = messageFrame.origin.y + messageFrame.size.height;
    mapFrame.size.height = self.view.bounds.size.height - keyboardFrame.size.height - messageFrame.size.height -
    statusFrame1.size.height - statusFrame2.size.height;
    _mapView.frame = mapFrame;

    statusFrame1.origin.y = mapFrame.origin.y + mapFrame.size.height;
    self.statusLabel1.frame = statusFrame1;

    statusFrame2.origin.y = statusFrame1.origin.y + statusFrame1.size.height;
    self.statusLabel2.frame = statusFrame2;
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
    [_events enterObject:WiniOSMessageDisplayFinishedEvent];
}

#pragma mark - show/hide Keyboard

- (void)keyboardDidShow:(NSNotification *)aNotification
{
    CGRect keyboardFrame = [[aNotification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardFrame = [self.view convertRect:keyboardFrame fromView:nil];
    [self layoutViewsWithKeyboardFrame:keyboardFrame];
}

- (void)keyboardDidHide:(NSNotification *)aNotification
{
    CGRect keyboardFrame = [[aNotification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardFrame = [self.view convertRect:keyboardFrame fromView:nil];
    keyboardFrame.size.height = 0.f;
    [self layoutViewsWithKeyboardFrame:keyboardFrame];
}

@end
