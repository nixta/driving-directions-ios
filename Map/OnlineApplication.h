//
//  OnlineApplication.h
//  Map
//
//  Created by Scott Sirowy on 9/13/11.
/*
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

/*
 Protocol that defines what an online application delegate should
 provide
 */

#import <Foundation/Foundation.h>

@class KeychainWrapper;

@protocol OnlineApplication <NSObject>

/*
 Need a keychain wrapper in order to save a user's name/password 
 into the device keychain
 */
@property (nonatomic, retain) KeychainWrapper *keychainWrapper;

//tbd

@end
