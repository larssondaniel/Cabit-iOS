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

+ (SettingsHelper *)sharedSettingsHelper;

- (NSString *)homeAddressShort;
- (NSString *)name;
- (NSString *)phoneNumber;
- (void)storeName:(NSString *)name;
- (void)storePhoneNumber:(NSString *)number;
- (void)storeHomeAddress:(SPGooglePlacesAutocompletePlace *)address
        withShortVersion:(NSString *)shortVersion;
- (bool)checkVerifiedUser;

@end
