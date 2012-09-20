//
//  OnlineApplication.h
//  Map
//
//  Created by Scott Sirowy on 9/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


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
