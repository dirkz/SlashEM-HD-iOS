//
//  Queue.h
//  UnNetHack
//
//  Created by Dirk Zimmermann on 5/16/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Queue : NSObject

/** Enter new event into the queue */
- (void)enterObject:(id)event;

/**
 Remove and return front-most event (blocking)
 @return The front-most event that has been removed from the queue
 */
- (id)leaveObject;

/** @return The front-most event */
- (id)frontObject;

@end
