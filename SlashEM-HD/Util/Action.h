//
//  Action.h
//  SlashEM-HD
//
//  Created by Dirk Zimmermann on 7/2/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Action : NSObject

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) id context;

+ (id)actionWithTitle:(NSString *)title context:(id)context block:(void (^)(Action *action, id context))block;

- (id)initWithTitle:(NSString *)title context:(id)context block:(void (^)(Action *action, id context))block;
- (void)invoke;

@end
