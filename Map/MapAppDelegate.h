//
//  MapAppDelegate.h
//  Map
//
//  Created by Scott Sirowy on 8/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

/*
 Specific app delegate for the map app
 */

#import <UIKit/UIKit.h>
#import "ArcGISAppDelegate.h"
#import "OnlineApplication.h"
#import "ArcGIS+App.h"

@class MapViewController;
@class KeyChainWrapper;

@interface MapAppDelegate : ArcGISAppDelegate <UIApplicationDelegate, OnlineApplication, UIAlertViewDelegate>
{
    KeychainWrapper         *_keychainWrapper;
    UIAlertView             *_networkAlertView;
    NSArray                 *_testOrganizations;
    
    AGSJSONRequestOperation *_organizationOp;
}

@property (nonatomic, retain) KeychainWrapper *keychainWrapper;
@property (nonatomic, retain) UIAlertView     *networkAlertView;
@property (nonatomic, retain) NSArray         *testOrganizations;

@end
