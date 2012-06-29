//
//  EventQueue.m
//  UnNetHack
//
//  Created by Dirk Zimmermann on 5/16/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import "Queue.h"

#import "NSLogger.h"

@implementation Queue
{
    NSMutableArray *_events;
    dispatch_queue_t _modifyEventsQueue;
    dispatch_semaphore_t _eventsSemaphore;
}

- (id)init
{
    if ((self = [super init])) {
        _events = [[NSMutableArray alloc] init];
        _modifyEventsQueue = dispatch_queue_create("com.dirkz.UnNetHack.modifyEventsQueue", DISPATCH_QUEUE_SERIAL);
        _eventsSemaphore = dispatch_semaphore_create(0);
    }
    return self;
}

- (void)enterObject:(id)event
{
    dispatch_async(_modifyEventsQueue, ^{
        LOG_UTIL(1, @"enterObject:%@", event);
        [_events addObject:event];
        dispatch_semaphore_signal(_eventsSemaphore);
    });
}

- (id)leaveObject {
    dispatch_semaphore_wait(_eventsSemaphore, DISPATCH_TIME_FOREVER);

    id __block event;
    dispatch_sync(_modifyEventsQueue, ^{
        event = [_events lastObject];
        [_events removeLastObject];
    });

    return event;
}

- (id)frontObject {
    id __block event;
    dispatch_sync(_modifyEventsQueue, ^{
        event = [_events lastObject];
    });
    LOG_UTIL(1, @"frontObject -> %@", event);
    return event;
}

- (void)dealloc
{
    dispatch_release(_modifyEventsQueue);
    dispatch_release(_eventsSemaphore);
}

@end
