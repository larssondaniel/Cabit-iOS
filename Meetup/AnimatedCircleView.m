//
//  AnimatedCircleView.m
//  Cabit
//
//  Created by Daniel Larsson on 2014-03-25.
//  Copyright (c) 2014 Meetup. All rights reserved.
//

#import "AnimatedCircleView.h"

#import <QuartzCore/QuartzCore.h>

#define MAX_RATIO 1
#define MIN_RATIO 0.1
#define STEP_RATIO 0.05

#define ANIMATION_DURATION 2

//repeat forever
#define ANIMATION_REPEAT HUGE_VALF

@implementation AnimatedCircleView

-(id)initWithCircle:(MKCircle *)circle{
    
    self = [super initWithCircle:circle];
    
    if(self){
        [self start];
    }
    
    return self;
}

-(void)dealloc{
    
    [self removeExistingAnimation];
}

-(void)start{
    
    [self removeExistingAnimation];
    
    //create the image
    UIImage* img = [UIImage imageNamed:@"redCircle"];
    imageView = [[UIImageView alloc] initWithImage:img];
    imageView.frame = CGRectMake(0, 0, 0, 0);
    [self addSubview:imageView];
    
    //opacity animation setup
    CABasicAnimation *opacityAnimation;
    
    opacityAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.duration = ANIMATION_DURATION;
    opacityAnimation.repeatCount = ANIMATION_REPEAT;
    //theAnimation.autoreverses=YES;
    opacityAnimation.fromValue = [NSNumber numberWithFloat:0.2];
    opacityAnimation.toValue = [NSNumber numberWithFloat:0.025];
    
    //resize animation setup
    CABasicAnimation *transformAnimation;
    
    transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    
    transformAnimation.duration = ANIMATION_DURATION;
    transformAnimation.repeatCount = ANIMATION_REPEAT;
    //transformAnimation.autoreverses=YES;
    transformAnimation.fromValue = [NSNumber numberWithFloat:MIN_RATIO];
    transformAnimation.toValue = [NSNumber numberWithFloat:MAX_RATIO];
    
    
    //group the two animation
    CAAnimationGroup *group = [CAAnimationGroup animation];
    
    group.repeatCount = ANIMATION_REPEAT;
    [group setAnimations:[NSArray arrayWithObjects:opacityAnimation, transformAnimation, nil]];
    group.duration = ANIMATION_DURATION;
    
    //apply the grouped animaton
    
    [imageView.layer addAnimation:group forKey:@"groupAnimation"];

    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = 4;
    animationGroup.repeatCount = INFINITY;
    animationGroup.animations = @[group];
    
    //[imageView.layer addAnimation:animationGroup forKey:@"pulse"];
}

-(void)stop{
    
    [self removeExistingAnimation];
}

-(void)removeExistingAnimation{
    
    if(imageView){
        [imageView.layer removeAllAnimations];
        [imageView removeFromSuperview];
        imageView = nil;
    }
}


- (void)drawMapRect:(MKMapRect)mapRect
          zoomScale:(MKZoomScale)zoomScale
          inContext:(CGContextRef)ctx
{
    //the circle center
    MKMapPoint mpoint = MKMapPointForCoordinate([[self overlay] coordinate]);
    
    //geting the radius in map point
    double radius = [(MKCircle*)[self overlay] radius];
    double mapRadius = radius * MKMapPointsPerMeterAtLatitude([[self overlay] coordinate].latitude);
    
    //calculate the rect in map coordination
    MKMapRect mrect = MKMapRectMake(mpoint.x - mapRadius, mpoint.y - mapRadius, mapRadius * 2, mapRadius * 2);
    
    //get the rect in pixel coordination and set to the imageView
    CGRect rect = [self rectForMapRect:mrect];
    
    if(imageView){
        imageView.frame = rect;
    }
}


@end