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

typedef enum {
    UIStateUndefined,
    UIStateYNQuestion,
    UIStatePoskey,
} UIState;

@interface SlashEMViewController ()

@property (nonatomic, strong) YNQuestionData *ynQuestionData;

@end

@implementation SlashEMViewController
{

    WiniOS *winios;
    Queue *events;
    UIState state;

}

@synthesize messageTextView;
@synthesize inputTextField;
@synthesize ynQuestionData = _ynQuestionData;

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
    state = UIStatePoskey;
    [inputTextField becomeFirstResponder];
}

- (void)handleClearMessages
{
    messageTextView.text = @"";
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    LOG_VIEW(1, @"%s %@", __PRETTY_FUNCTION__, segue);
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string
{
    if (string.length > 0) {
        unichar ch = [string characterAtIndex:0];
        switch (state) {
            case UIStateYNQuestion: {
                KeyEvent *event = [KeyEvent eventWithKey:ch];
                [events enterObject:event];
                self.ynQuestionData = nil;
            }
                break;
            case UIStatePoskey: {
                PosKeyEvent *event = [PosKeyEvent eventWithKey:ch];
                [events enterObject:event];
                state = UIStateUndefined;
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
        state = UIStateYNQuestion;
    } else {
        state = UIStateUndefined;
    }
    _ynQuestionData = yn;
}

@end
