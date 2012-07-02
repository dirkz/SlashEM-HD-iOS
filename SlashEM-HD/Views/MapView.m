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
#import "NHDirection.h"

#import "hack.h" // MAX_GLYPH

extern short glyph2tile[MAX_GLYPH];
extern int total_tiles_used;

@interface MapView ()

@property (nonatomic, readonly) CGSize tilesizePoints;
@property (nonatomic, readonly) UIImage *tileMapImage;

@end

@implementation MapView
{
    NHMapWindow *_mapWindow;
    TileCache *_tilecache;
}

@synthesize delegate = _delegate;
@synthesize mapWindow = _mapWindow;

- (void)setup
{
    UIImage *image = [UIImage imageNamed:@"Geoduck SlashEM 10x20.png"];
    _tilecache = [[TileCache alloc] initWithImage:image tileSizePoints:CGSizeMake(10.f, 20.f)];

    UITapGestureRecognizer *tapGestureRecognizerSingle = [[UITapGestureRecognizer alloc]
                                                          initWithTarget:self action:@selector(handleSingleTap:)];
    [self addGestureRecognizer:tapGestureRecognizerSingle];

    UITapGestureRecognizer *tapGestureRecognizerDouble = [[UITapGestureRecognizer alloc]
                                                          initWithTarget:self action:@selector(handleDoubleTap:)];
    tapGestureRecognizerDouble.numberOfTapsRequired = 2;
    [self addGestureRecognizer:tapGestureRecognizerDouble];

    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc]
                                                                initWithTarget:self action:@selector(handleLongPress:)];
    [self addGestureRecognizer:longPressGestureRecognizer];
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

            // if glyph is not defined, use the first tilenumber not used by the tileset
            NSUInteger tileNumber = (glyph != NHMapWindowNoGlyph) ? glyph2tile[glyph] : total_tiles_used;

            CGLayerRef layer = [_tilecache layerForTileNumber:tileNumber context:context];
            CGContextDrawLayerInRect(context, [self destinationRectForTileAtCol:i row:j], layer);
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

#pragma mark - UIGestureRecognizer

- (void)getTileX:(NSUInteger *)tileX tileY:(NSUInteger *)tileY fromViewLocation:(CGPoint)location
{
    CGPoint characterLocation = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    NSInteger tileDX = (location.x - characterLocation.x) / self.tilesizePoints.width;
    NSInteger tileDY = (location.y - characterLocation.y) / self.tilesizePoints.height;
    *tileX = _mapWindow.clipX + tileDX;
    *tileY = _mapWindow.clipY + tileDY;
}

- (NHDirection)getDirectionFromViewLocation:(CGPoint)location
{
    CGPoint characterLocation = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    CGPoint delta = CGPointMake(location.x - characterLocation.x,
                                -(location.y - characterLocation.y)); // Note y inversion for euclidean
    return NHDirectionFromEuclidieanUnitDelta(delta.x, delta.y);
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    NSUInteger tileX, tileY;
    [self getTileX:&tileX tileY:&tileY fromViewLocation:[recognizer locationInView:self]];
    NHDirection direction = [self getDirectionFromViewLocation:[recognizer locationInView:self]];
    [_delegate mapView:self handleSingleTapTileX:tileX tileY:tileY direction:direction];
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer
{
    NSUInteger tileX, tileY;
    [self getTileX:&tileX tileY:&tileY fromViewLocation:[recognizer locationInView:self]];
    NHDirection direction = [self getDirectionFromViewLocation:[recognizer locationInView:self]];
    [_delegate mapView:self handleDoubleTapTileX:tileX tileY:tileY direction:direction];
    LOG_VIEW(1, @"double tap");
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        NSUInteger tileX, tileY;
        [self getTileX:&tileX tileY:&tileY fromViewLocation:[recognizer locationInView:self]];
        [_delegate mapView:self handleLongPressTileX:tileX tileY:tileY locationInView:[recognizer locationInView:self]];
    }
}

@end
