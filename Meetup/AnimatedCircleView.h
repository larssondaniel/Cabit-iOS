//
//  AnimatedCircleView.h
//  Cabit
//
//  Created by Daniel Larsson on 2014-03-25.
//  Copyright (c) 2014 Meetup. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MapKit/MapKit.h>

@interface AnimatedCircleView : MKCircleView{
    
    UIImageView* imageView;
}

-(void)start;
-(void)stop;

@end