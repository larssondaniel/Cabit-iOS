//
//  GlowLabel.h
//  Cabit
//
//  Created by Daniel Larsson on 2014-03-26.
//  Copyright (c) 2014 Meetup. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GlowLabel : UILabel {
    BOOL selected;
    UIColor *selectedColor;
    UIColor *unselectedColor;
}

@property (nonatomic, retain) UIColor *selectedColor;
@property (nonatomic, retain) UIColor *unselectedColor;

- (void)setSelected:(BOOL)isSelected;
- (BOOL)selected;


@end