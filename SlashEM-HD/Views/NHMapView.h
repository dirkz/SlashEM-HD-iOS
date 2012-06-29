//
//  NHMapView.h
//  SlashEM-HD
//
//  Created by Dirk Zimmermann on 6/24/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NHMapWindow;

@protocol NHMapView  <NSObject>

/** Typically called by a view controller to draw the map */
- (void)displayMapWindow:(NHMapWindow *)w;

@end
