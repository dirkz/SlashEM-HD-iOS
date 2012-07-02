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
#import "ContextMenuViewController.h"
#import "Action.h"

typedef enum {
    UIStateUndefined,
    UIStateYNQuestion,
    UIStatePoskey,
} UITextInputState;

NSString * const NetHackMainStoryboard = @"MainStoryboard";
NSString * const NetHackMessageMenuWindowSegue = @"NetHackMessageMenuWindowSegue";
NSString * const NetHackMenuViewSegue = @"NetHackMenuViewSegue";
NSString * const NetHackContextMenuSegue = @"ContextMenuSegue";
NSString * const NetHackContextMenuViewController = @"NetHackContextMenuViewController"; // storyboard id

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

    /** Current UIPopoverViewController visible */
    UIPopoverController * _displayedPopoverController;
}

@synthesize messageTextView = _messageTextView;
@synthesize inputTextField = _inputTextField;
@synthesize statusLabel1 = _statusLabel1;
@synthesize statusLabel2 = _statusLabel2;
@synthesize mapView = _mapView;
@synthesize ynQuestionData = _ynQuestionData;
@synthesize menuWindow = _menuWindow;
@synthesize state = _state;

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _inputTextField.frame = CGRectZero;
        _winios = [[WiniOS alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    _mapView.delegate = self;
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
    _ynQuestionData = question;
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
    _state = UIStatePoskey;
    [_inputTextField becomeFirstResponder];
}

- (void)handleClearMessages
{
    _messageTextView.text = @"";
}

- (void)handleMenuWindow:(NHMenuWindow *)window
{
    _menuWindow = window;
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
    _menuWindow = window;
    [self performSegueWithIdentifier:NetHackMessageMenuWindowSegue sender:nil];
}

- (void)handleMapDisplay:(NHMapWindow *)window block:(BOOL)block
{
    [_mapView displayMapWindow:window];
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
        menuViewController.menuWindow = _menuWindow;
        if (_menuWindow.prompt) {
            menuViewController.title = _menuWindow.prompt;
        }
    } else if ([segue.identifier isEqualToString:NetHackMessageMenuWindowSegue]) {
        MessageViewController *vc = segue.destinationViewController;
        vc.menuWindow = _menuWindow;
        vc.delegate = self;
    }  else if ([segue.identifier isEqualToString:NetHackContextMenuSegue]) {
        LOG_VIEW(1, @"source %@ destination %@", segue.sourceViewController, segue.destinationViewController);
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string
{
    if (string.length > 0) {
        unichar ch = [string characterAtIndex:0];
        switch (_state) {
            case UIStateYNQuestion: {
                [_events enterObject:[KeyEvent eventWithKey:ch]];
                _ynQuestionData = nil;
            }
                break;
            case UIStatePoskey: {
                [_events enterObject:[PosKeyEvent eventWithKey:ch]];
                _state = UIStateUndefined;
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
        _state = UIStateYNQuestion;
    } else {
        _state = UIStateUndefined;
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
    CGRect statusFrame1 = _statusLabel1.frame;
    CGRect statusFrame2 = _statusLabel2.frame;

    CGRect mapFrame = _mapView.frame;
    mapFrame.origin.y = messageFrame.origin.y + messageFrame.size.height;
    mapFrame.size.height = self.view.bounds.size.height - keyboardFrame.size.height - messageFrame.size.height -
    statusFrame1.size.height - statusFrame2.size.height;
    _mapView.frame = mapFrame;

    statusFrame1.origin.y = mapFrame.origin.y + mapFrame.size.height;
    _statusLabel1.frame = statusFrame1;

    statusFrame2.origin.y = statusFrame1.origin.y + statusFrame1.size.height;
    _statusLabel2.frame = statusFrame2;
}

#pragma mark - MenuViewControllerDelegate

- (void)menuViewController:(MenuViewController *)viewController cancelMenuWindow:(NHMenuWindow *)window
{
    _menuWindow.numberOfItemsSelected = -1;
    [self dismissDisplayedViewController];
}

- (void)menuViewController:(MenuViewController *)viewController pickNoneMenuWindow:(NHMenuWindow *)window
{
}

- (void)menuViewController:(MenuViewController *)viewController pickOneItem:(NHMenuItem *)item
                menuWindow:(NHMenuWindow *)window
{
    _menuWindow.numberOfItemsSelected = 1;

    *_menuWindow.selected = malloc(sizeof(menu_item));
    (*_menuWindow.selected)->count = -1;
    (*_menuWindow.selected)->item.a_int = item.identifier.a_int;

    [self dismissDisplayedViewController];
}

- (void)menuViewController:(MenuViewController *)viewController pickAnyItems:(NSArray *)items
                menuWindow:(NHMenuWindow *)window
{
    _menuWindow.numberOfItemsSelected = items.count;

    *_menuWindow.selected = malloc(sizeof(menu_item) * items.count);
    NSUInteger i = 0;
    for (NHMenuItem *item in items) {
        (*_menuWindow.selected)[i].count = item.selectedAmount;
        (*_menuWindow.selected)[i].item.a_int = item.identifier.a_int;
        i++;
    }

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

#pragma mark - MapViewDelegate

- (void)mapView:(id<NHMapView>)mapView handleSingleTapTileX:(NSUInteger)tileX tileY:(NSUInteger)tileY
      direction:(NHDirection)direction
{
    if (_state == UIStatePoskey) {
        if (_winios.wantsPosition) {
            [_events enterObject:[PosKeyEvent eventWithKey:0 x:tileX y:tileY mod:0]];
            _state = UIStateUndefined;
        } else {
            char directionKey = 0;
            switch (direction) {
                case NHDirectionNorth:
                    directionKey = 'k';
                    break;
                case NHDirectionNorthEast:
                    directionKey = 'u';
                    break;
                case NHDirectionEast:
                    directionKey = 'l';
                    break;
                case NHDirectionSouthEast:
                    directionKey = 'n';
                    break;
                case NHDirectionSouth:
                    directionKey = 'j';
                    break;
                case NHDirectionSouthWest:
                    directionKey = 'b';
                    break;
                case NHDirectionWest:
                    directionKey = 'h';
                    break;
                case NHDirectionNorthWest:
                    directionKey = 'y';
                    break;
                case NHDirectionError:
                    NSAssert(NO, @"Direction Error");
                    break;
            }
            [_events enterObject:[PosKeyEvent eventWithKey:directionKey]];
            _state = UIStateUndefined;
        }
    } else {
        LOG_VIEW(1, @"Ignoring map tap, state is %d", _state);
    }
}

- (void)mapView:(id<NHMapView>)mapView handleDoubleTapTileX:(NSUInteger)tileX tileY:(NSUInteger)tileY
      direction:(NHDirection)direction
{
    [_events enterObject:[PosKeyEvent eventWithKey:'g']];
    [self mapView:mapView handleSingleTapTileX:tileX tileY:tileY direction:direction];
}

- (void)mapView:(id<NHMapView>)mapView handleLongPressTileX:(NSUInteger)tileX tileY:(NSUInteger)tileY
 locationInView:(CGPoint)location
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:NetHackMainStoryboard bundle:nil];
    ContextMenuViewController *vc = [storyboard
                                     instantiateViewControllerWithIdentifier:NetHackContextMenuViewController];
    vc.actions = [NSArray arrayWithObjects:
                  [Action actionWithTitle:@"Go to" context:nil block:^(Action *action, id context) {
        if (_state == UIStatePoskey) {
            int glyph = [self.mapView.mapWindow glyphAtX:tileX y:tileY];
            if (glyph != NHMapWindowNoGlyph) {
                [_events enterObject:[PosKeyEvent eventWithKey:0 x:tileX y:tileY mod:0]];
                _state = UIStateUndefined;
            }
        }
        [_displayedPopoverController dismissPopoverAnimated:NO];
    }],
                  nil];
    _displayedPopoverController = [[UIPopoverController alloc] initWithContentViewController:vc];
    [_displayedPopoverController presentPopoverFromRect:CGRectMake(location.x-1, location.y-1, 1.f, 1.f)
                                                 inView:self.mapView
                               permittedArrowDirections:UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown |
     UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionRight animated:NO];
}

@end
