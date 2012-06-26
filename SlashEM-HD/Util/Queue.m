//
//  EventQueue.m
//  UnNetHack
//
//  Created by Dirk Zimmermann on 5/16/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import "Queue.h"

@implementation Queue
{
    NSMutableArray *events;
    dispatch_queue_t modifyEventsQueue;
    dispatch_semaphore_t eventsSemaphore;
}

- (id)init
{
    if ((self = [super init])) {
        events = [[NSMutableArray alloc] init];
        modifyEventsQueue = dispatch_queue_create("com.dirkz.UnNetHack.modifyEventsQueue", DISPATCH_QUEUE_SERIAL);
        eventsSemaphore = dispatch_semaphore_create(0);
    }
    return self;
}

- (void)enterObject:(id)event
{
    dispatch_async(modifyEventsQueue, ^{
        [events addObject:event];
        dispatch_semaphore_signal(eventsSemaphore);
    });
}

- (id)leaveObject {
    dispatch_semaphore_wait(eventsSemaphore, DISPATCH_TIME_FOREVER);

    id __block event;
    dispatch_sync(modifyEventsQueue, ^{
        event = [events lastObject];
        [events removeLastObject];
    });

    return event;
}

- (id)frontObject {
    id __block event;
    dispatch_sync(modifyEventsQueue, ^{
        event = [events lastObject];
    });
    return event;
}

- (void)dealloc
{
    dispatch_release(modifyEventsQueue);
    dispatch_release(eventsSemaphore);
}

@end
