/*
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

/*
 Specific app delegate for the map app
 */

#import <UIKit/UIKit.h>
#import "ArcGISAppDelegate.h"
#import <ArcGIS/ArcGIS.h>

#import "RoutingDelegate.h"

@class MapViewController;


@interface MapAppDelegate : ArcGISAppDelegate <UIApplicationDelegate, UIAlertViewDelegate>
{    
    UIAlertView             *_networkAlertView;
    NSArray                 *_testOrganizations;
    
    AGSJSONRequestOperation *_organizationOp;
}

@property (nonatomic, strong) UIAlertView     *networkAlertView;
@property (nonatomic, strong) NSArray         *testOrganizations;
@property (nonatomic, strong) AGSMapView      *mapView;

- (AGSPoint*)convertCoordinatesToPoint:(CLLocationCoordinate2D)coordinates;
@property (nonatomic, retain) id <RoutingDelegate> routeDelegate;

@end
