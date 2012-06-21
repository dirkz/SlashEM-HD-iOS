//
//  NhWindow.h
//  UnNetHack
//
//  Created by Dirk Zimmermann on 5/18/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NhWindow : NSObject

@property (nonatomic, readonly) int type;
@property (nonatomic, readonly) NSString *typeName;

- (id)initWithType:(int)t;

@end
