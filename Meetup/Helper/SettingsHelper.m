//
//  SettingsHelper.m
//  Cabit
//
//  Created by Daniel Larsson on 2014-03-02.
//  Copyright (c) 2014 Meetup. All rights reserved.
//

#import "SettingsHelper.h"

@implementation SettingsHelper

+ (id)sharedSettingsHelper
{
    static SettingsHelper *sharedInstance = nil;
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        sharedInstance = [SettingsHelper alloc];
        sharedInstance = [sharedInstance init];
    });
    
    return sharedInstance;
}

- (void)storeName:(NSString *)name
{
    NSLog(@"Storing name: %@", name);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:name forKey:@"name"];
    [defaults synchronize];
}

- (void)storePhoneNumber:(NSString *)number
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:number forKey:@"phoneNumber"];
    [defaults synchronize];
}

@end
