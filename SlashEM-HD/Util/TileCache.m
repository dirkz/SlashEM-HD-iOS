//
//  TileCache.m
//  SlashEM-HD
//
//  Created by Dirk Zimmermann on 6/25/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import "TileCache.h"

#import "NSLogger.h"

@interface TileCache ()

@property (nonatomic, readonly) NSMutableDictionary *tiles;

@end

@implementation TileCache
{
    NSUInteger _numberOfRows;
    NSUInteger _numberOfCols;
    NSUInteger _numberOfTiles;
    CGSize _tilesizePixels;
}

@synthesize image = _image;
@synthesize tilesizePoints = _tilesizePoints;
@synthesize tiles = _tiles;

- (id)initWithImage:(UIImage *)image tileSizePoints:(CGSize)tilesizePoints
{
    self = [super init];
    if (self) {
        _image = image;
        _tilesizePoints = tilesizePoints;
        _tilesizePixels = tilesizePoints;
        _tilesizePixels.width *= image.scale;
        _tilesizePixels.height *= image.scale;
        _numberOfCols = _image.size.width / _tilesizePoints.width;
        _numberOfRows = _image.size.height / _tilesizePoints.height;
        _numberOfTiles = _numberOfCols * _numberOfRows;
    }
    return self;
}

- (CGLayerRef)layerForTileNumber:(NSUInteger)tileNumber context:(CGContextRef)context
{
    CGLayerRef layer = [self cachedLayerForTileNumber:tileNumber];
    if (!layer) {
        NSUInteger col = tileNumber % _numberOfCols;
        NSUInteger row = tileNumber / _numberOfCols; // image coordinate system starts at top left!
        CGRect sourceImageRect = CGRectMake(col * _tilesizePixels.width, row * _tilesizePixels.height,
                                            _tilesizePixels.width, _tilesizePixels.height);
        CGImageRef image = CGImageCreateWithImageInRect(_image.CGImage, sourceImageRect);
        layer = [self createLayerForImageRef:image context:context];
        CGImageRelease(image);
        [self.tiles setObject:(__bridge_transfer id) layer forKey:[NSNumber numberWithInt:tileNumber]];
    }
    return layer;
}

#pragma mark - Util

- (CGLayerRef)cachedLayerForTileNumber:(NSUInteger)tileNumber
{
    return (__bridge CGLayerRef) [self.tiles objectForKey:[NSNumber numberWithInt:tileNumber]];
}

- (CGLayerRef)createLayerForImageRef:(CGImageRef)image context:(CGContextRef)context
{
    CGLayerRef layer = CGLayerCreateWithContext(context, _tilesizePoints, NULL);
    CGContextRef layerContext = CGLayerGetContext(layer);
    CGContextDrawImage(layerContext, CGRectMake(0.f, 0.f, _tilesizePoints.width, _tilesizePoints.height), image);
    return layer;
}

#pragma mark - Properties

- (NSMutableDictionary *)tiles {
    if (!_tiles) {
        _tiles = [[NSMutableDictionary alloc] initWithCapacity:_numberOfTiles];
    }
    return _tiles;
}

@end
