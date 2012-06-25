//
//  TileCache.h
//  SlashEM-HD
//
//  Created by Dirk Zimmermann on 6/25/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TileCache : NSObject

@property (nonatomic, readonly) CGSize tilesizePoints;
@property (nonatomic, readonly) UIImage *image;

- (id)initWithImage:(UIImage *)img tileSizePoints:(CGSize)tilesizePoints;
- (CGLayerRef)layerForTileNumber:(NSUInteger)tileNumber context:(CGContextRef)context;

@end
