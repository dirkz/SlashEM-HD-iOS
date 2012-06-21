//
//  KeyEvent.h
//  UnNetHack
//
//  Created by Dirk Zimmermann on 5/17/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeyEvent : NSObject

@property (nonatomic, readonly) char key;

+ (id)eventWithKey:(char)k;

- (id)initWithKey:(char)k;

@end
