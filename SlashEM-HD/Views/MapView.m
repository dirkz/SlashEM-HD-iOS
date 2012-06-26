//
//  MapView.m
//  SlashEM-HD
//
//  Created by Dirk Zimmermann on 6/24/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import "MapView.h"

#import "NHMapWindow.h"
#import "NSLogger.h"
#import "TileCache.h"

#import "hack.h" // MAX_GLYPH

extern short glyph2tile[MAX_GLYPH];

@interface MapView ()

@property (nonatomic, readonly) CGSize tilesizePoints;
@property (nonatomic, readonly) UIImage *tileMapImage;

@end

@implementation MapView
{
    NHMapWindow *_mapWindow;
    TileCache *_tilecache;
}

- (void)setup
{
    UIImage *image = [UIImage imageNamed:@"Geoduck SlashEM 10x20.png"];
    _tilecache = [[TileCache alloc] initWithImage:image tileSizePoints:CGSizeMake(10.f, 20.f)];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();

    // switch to right-handed coordinate system (quartz)
    CGContextTranslateCTM(context, 0.0f, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0f, -1.0f);

    for (int j = 0; j < _mapWindow.rows; ++j) {
        for (int i = 0; i < _mapWindow.cols; ++i) {
            int glyph = [_mapWindow glyphAtX:i y:j];
            if (glyph != NHMapWindowNoGlyph) {
                NSUInteger tileNumber = glyph2tile[glyph];
                CGLayerRef layer = [_tilecache layerForTileNumber:tileNumber context:context];
                CGContextDrawLayerInRect(context, [self destinationRectForTileAtCol:i row:j], layer);
            }
        }
    }
}

#pragma mark - Util

/** @return Destination rect (in points) for the given tile (quartz coordinate system!) */
- (CGRect)destinationRectForTileAtCol:(NSInteger)col row:(NSInteger)row
{
    CGSize offset = CGSizeMake(-_mapWindow.clipX * self.tilesizePoints.width // move character to the very left
                               - self.tilesizePoints.width/2 // move half tile to the left (only middle is shown)
                               + self.bounds.size.width/2, // translate to middle of screen
                               -(_mapWindow.rows - _mapWindow.clipY) * self.tilesizePoints.height // move to buttom and
                               // notice how we had to convert to quartz coordinate system since NH starts row 0
                               // at the top of the screen
                               -self.tilesizePoints.height/2 // move half tile to buttom (only middle is shown)
                               + self.bounds.size.height/2); // translate to middle of screen
    NSInteger rowFromButton = _mapWindow.rows - row;
    CGRect r = CGRectMake(col * self.tilesizePoints.width + offset.width,
                          rowFromButton * self.tilesizePoints.height + offset.height,
                          self.tilesizePoints.width, self.tilesizePoints.height);
    return r;
}

#pragma mark - NHMapView

- (void)displayMapWindow:(NHMapWindow *)w
{
    _mapWindow = w;
    [self setNeedsDisplay];
}

#pragma mark - Properties

- (CGSize)tilesizePoints
{
    return _tilecache.tilesizePoints;
}

- (UIImage *)tileMapImage
{
    return _tilecache.image;
}

@end
