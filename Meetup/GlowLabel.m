//
//  GlowLabel.m
//  Cabit
//
//  Created by Daniel Larsson on 2014-03-26.
//  Copyright (c) 2014 Meetup. All rights reserved.
//

#import "GlowLabel.h"

#define GLOW_OFFSET     CGSizeZero
#define GLOW_RADIUS     10


@implementation GlowLabel

@synthesize selectedColor, unselectedColor;

- (void)dealloc {
    self.selectedColor = nil;
    self.unselectedColor = nil;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.textAlignment = NSTextAlignmentRight;
        // 18
        self.font = [UIFont fontWithName:@"OpenSans" size:10];
        self.backgroundColor = [UIColor clearColor];
        
        //initialize with default colors
        self.selectedColor = [UIColor blackColor];
        self.unselectedColor = [UIColor grayColor];
        //init as unselected
        selected = NO;
    }
    return self;
}

- (void)setSelected:(BOOL)isSelected {
    selected = isSelected;
    self.textColor = (selected ? self.selectedColor : self.unselectedColor);
    [self setNeedsDisplay];
}

- (BOOL)selected {
    return selected;
}

- (void)drawTextInRect:(CGRect)rect
{
    if (selected) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetShadowWithColor(context, GLOW_OFFSET, GLOW_RADIUS, [self.selectedColor CGColor]);
    }
	[super drawTextInRect:rect];
}

@end