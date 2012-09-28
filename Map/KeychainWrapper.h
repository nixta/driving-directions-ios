//
//  KeyChainWrapper.h
//  ArcGISMobile
//
//  Created by Mark Dostal on 2/14/11.
/*
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

#import <Foundation/Foundation.h>

@interface KeychainWrapper : NSObject {
    NSMutableDictionary        *_keychainData;
    NSMutableDictionary        *_genericPasswordQuery;
}

@property (nonatomic, strong) NSMutableDictionary *keychainData;
@property (nonatomic, strong) NSMutableDictionary *genericPasswordQuery;

- (void)setPassword:(id)password forUser:(id)user;
- (id)getPassword;
- (id)getUser;
- (BOOL)isLoggedIn;
- (void)resetKeychainItem;

@end
