//
//  YNData.h
//  UnNetHack
//
//  Created by Dirk Zimmermann on 5/17/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YNQuestionData : NSObject

@property (nonatomic, readonly) NSString *prompt;
@property (nonatomic, readonly) NSString *choices;
@property (nonatomic, readonly) unichar defaultChoice;

+ (id)dataWithPrompt:(NSString *)p choices:(NSString *)ch defaultChoice:(unichar)def;
- (id)initWithPrompt:(NSString *)p choices:(NSString *)ch defaultChoice:(unichar)def;

@end
