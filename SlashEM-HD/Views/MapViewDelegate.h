//
//  MapViewDelegate.h
//  SlashEM-HD
//
//  Created by Dirk Zimmermann on 6/29/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NHMapView.h"
#import "NHDirection.h"

@protocol MapViewDelegate <NSObject>

- (void)mapView:(id<NHMapView>)mapView handleSingleTapLocation:(CGPoint)location
          tileX:(NSUInteger)tileX tileY:(NSUInteger)tileY direction:(NHDirection)direction;

@end
