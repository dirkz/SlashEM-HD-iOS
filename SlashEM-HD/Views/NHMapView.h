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

- (void)displayMapWindow:(NHMapWindow *)w;

@end
