//
//  MapView.h
//  SlashEM-HD
//
//  Created by Dirk Zimmermann on 6/24/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NHMapView.h"
#import "MapViewDelegate.h"

@interface MapView : UIView <NHMapView>

@property (nonatomic, weak) id<MapViewDelegate> delegate;

@end
