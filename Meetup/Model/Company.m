//
//  Company.m
//  Meetup
//
//  Created by Daniel Larsson on 2013-11-23.
//  Copyright (c) 2013 Meetup. All rights reserved.
//

#import "Company.h"

@implementation Company

- (id)initWithName:(NSString *)name
{
    self = [super init];
    self.name = name;
    
    return self;
}

@end
