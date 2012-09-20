//
//  KeyChainWrapper.h
//  ArcGISMobile
//
//  Created by Mark Dostal on 2/14/11.
//  Copyright 2011 ESRI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeychainWrapper : NSObject {
    NSMutableDictionary        *_keychainData;
    NSMutableDictionary        *_genericPasswordQuery;
}

@property (nonatomic, retain) NSMutableDictionary *keychainData;
@property (nonatomic, retain) NSMutableDictionary *genericPasswordQuery;

- (void)setPassword:(id)password forUser:(id)user;
- (id)getPassword;
- (id)getUser;
- (BOOL)isLoggedIn;
- (void)resetKeychainItem;

@end
