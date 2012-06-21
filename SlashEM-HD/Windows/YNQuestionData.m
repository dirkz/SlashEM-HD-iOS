//
//  YNData.m
//  UnNetHack
//
//  Created by Dirk Zimmermann on 5/17/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import "YNQuestionData.h"

@implementation YNQuestionData

@synthesize prompt;
@synthesize choices;
@synthesize defaultChoice;

+ (id)dataWithPrompt:(NSString *)p choices:(NSString *)ch defaultChoice:(unichar)def
{
    return [[self alloc] initWithPrompt:p choices:ch defaultChoice:def];
}

- (id)initWithPrompt:(NSString *)p choices:(NSString *)ch defaultChoice:(unichar)def
{
    if ((self = [super init])) {
        prompt = [p copy];
        choices = [ch copy];
        defaultChoice = def;
    }
    return self;
}

@end
