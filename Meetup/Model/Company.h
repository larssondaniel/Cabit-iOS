//
//  Company.h
//  Meetup
//
//  Created by Daniel Larsson on 2013-11-23.
//  Copyright (c) 2013 Meetup. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Company : NSObject

@property (nonatomic, strong) NSString *name;

- (id)initWithName:(NSString *)name;

@end
