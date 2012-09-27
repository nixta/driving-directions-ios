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

#import "routingDelegate.h"

@class MapViewController;
@class KeyChainWrapper;

@interface MapAppDelegate : ArcGISAppDelegate <UIApplicationDelegate, OnlineApplication, UIAlertViewDelegate>
{
    KeychainWrapper         *_keychainWrapper;
    UIAlertView             *_networkAlertView;
    NSArray                 *_testOrganizations;
    
    AGSJSONRequestOperation *_organizationOp;
}

@property (nonatomic, strong) KeychainWrapper *keychainWrapper;
@property (nonatomic, strong) UIAlertView     *networkAlertView;
@property (nonatomic, strong) NSArray         *testOrganizations;

- (AGSPoint*)convertCoordinatesToPoint:(CLLocationCoordinate2D)coordinates;
@property (nonatomic, retain) id <routingDelegate> routeDelegate;

@end
