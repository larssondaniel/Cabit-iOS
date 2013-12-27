//
//  MapTileOverlayView.m
//  Meetup
//
//  Created by Daniel Larsson on 2013-11-28.
//  Copyright (c) 2013 Meetup. All rights reserved.
//

#import "MapTileOverlayView.h"

@implementation MapTileOverlayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context {
    //CGContextSetRGBFillColor(context, 1, 1, 1, 0.8);  //use whatever color to mute the beige
    CGContextSetBlendMode(context, kCGBlendModeColor);  //check docs for other blend modes
    CGContextSetGrayFillColor(context, 0.8, 0.4);
    CGContextFillRect(context, [self rectForMapRect:mapRect]);
}

@end
