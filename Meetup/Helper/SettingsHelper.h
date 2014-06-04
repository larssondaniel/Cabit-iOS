//
//  SettingsHelper.h
//  Cabit
//
//  Created by Daniel Larsson on 2014-03-02.
//  Copyright (c) 2014 Cabit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPGooglePlacesAutocompletePlace.h"

@interface SettingsHelper : NSObject

+ (SettingsHelper *) sharedSettingsHelper;

- (void)storeName:(NSString *)name;
- (void)storePhoneNumber:(NSString *)number;
- (void)storeHomeAddress:(SPGooglePlacesAutocompletePlace *)address;

@end
