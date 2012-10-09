//
//  MapAppDelegate.m
//  Map
//
//  Created by Scott Sirowy on 8/30/11.
//  Copyright 2011 ESRI. All rights reserved.
/*
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

#import "MapAppDelegate.h"
#import "MapViewController.h"
#import "MapAppSettings.h"
#import "MapShareUtility.h"
#import "ArcGISMobileConfig.h"

#import <SystemConfiguration/SystemConfiguration.h>
#import <MapKit/MapKit.h>

#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

@interface MapAppDelegate () 

- (BOOL)validNetworkConnection;

@property (nonatomic, strong) AGSJSONRequestOperation *organizationOp;

@end

@implementation MapAppDelegate


@synthesize networkAlertView = _networkAlertView;
@synthesize organizationOp = _organizationOp;
@synthesize testOrganizations = _testOrganizations;
@synthesize routeDelegate = _routeDelegate;
@synthesize mapView = _mapView;

#pragma mark -
#pragma mark UIApplicationDelegate

///
/// Called by Apple Maps
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    // Are we being launched by Maps to show a route?
    if ([MKDirectionsRequest isDirectionsRequestURL:url]) {
        
        // Decode the directions request from the launch URL.
        MKDirectionsRequest *request = [[MKDirectionsRequest alloc] initWithContentsOfURL:url];
        MKMapItem *startItem = [request source];
        MKMapItem *endItem = [request destination];
        
        AGSPoint *startPoint = nil;
        AGSPoint *endPoint = nil;
        
        if ([startItem isCurrentLocation]) {
           
            endPoint = [self convertCoordinatesToPoint:endItem.placemark.coordinate];
            
            
        } else if ([endItem isCurrentLocation]) {
            
            startPoint = [self convertCoordinatesToPoint:startItem.placemark.coordinate];
         
            
        } else {
            
            endPoint = [self convertCoordinatesToPoint:endItem.placemark.coordinate];
            startPoint = [self convertCoordinatesToPoint:startItem.placemark.coordinate];
        
        }
        
        [self.routeDelegate appleMapsCalled:startPoint withEnd:endPoint];
        
        return YES;
    }
    
    return NO;
}

- (AGSPoint*)convertCoordinatesToPoint:(CLLocationCoordinate2D)coordinates
{
    AGSSpatialReference *wgsReference = [[AGSSpatialReference alloc] initWithWKID:4326];
    AGSSpatialReference *webMercatorSpatialReference = [[AGSSpatialReference alloc] initWithWKID:102100];
    AGSPoint *point = [[AGSPoint alloc] initWithX:coordinates.longitude y:coordinates.latitude spatialReference:wgsReference];
    AGSGeometryEngine *engine = [[AGSGeometryEngine alloc] init];
    AGSPoint *webMercatorPoint = (AGSPoint*)[engine projectGeometry:point toSpatialReference:webMercatorSpatialReference];
    
    return webMercatorPoint;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{	
    [self loadSplashScreen];
    
    //[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
    
	// check for network conncetion
	// at this point, our splash screen is loaded so the AlertView shows
	// on top of it
	if (![self validNetworkConnection]) {
        self.networkAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Internet Connection", nil)
                                                            message:NSLocalizedString(@"NoInternetError", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Try again", nil)
                                                  otherButtonTitles:nil];
        self.networkAlertView.delegate = self;
        [self.networkAlertView show];
        
		return NO;
    }
	
	NSDictionary *appDict = [NSDictionary dictionaryWithObjectsAndKeys:
							 application, @"app",
							 launchOptions, @"options",
							 nil];						
	
	[self performSelector:@selector(launchMethod:) withObject:appDict afterDelay:0.0];
    
       
	return YES;
}



#pragma mark -
#pragma mark NetworkConnection

//The following was adapted from the Rechability Apple sample
- (BOOL)validNetworkConnection
{
    struct sockaddr_in zeroAddress;
	bzero(&zeroAddress, sizeof(zeroAddress));
	zeroAddress.sin_len = sizeof(zeroAddress);
	zeroAddress.sin_family = AF_INET;
    
	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&zeroAddress);
    
    SCNetworkReachabilityFlags flags = 0;
    Boolean bFlagsValid = SCNetworkReachabilityGetFlags(reachability, &flags);
    CFRelease(reachability);
    
    if (!bFlagsValid)
        return NO;
    
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
	{
		// if target host is not reachable
		return NO;//NotReachable;
	}
    
	BOOL retVal = NO;
	
	if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
	{
		// if target host is reachable and no connection is required
		//  then we'll assume (for now) that your on Wi-Fi
		retVal = YES;
	}
	
	
	if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
         (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
	{
        // ... and the connection is on-demand (or on-traffic) if the
        //     calling application is using the CFSocketStream or higher APIs
        
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
        {
            // ... and no [user] intervention is needed
            retVal = YES;
        }
    }
	
	if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
	{
		// ... but WWAN connections are OK if the calling application
		//     is using the CFNetwork (CFSocketStream?) APIs.
		retVal = YES;
	}
    
	return retVal;
}

-(void)saveAppState
{
    MapAppSettings *mas = (MapAppSettings *)self.appSettings;
    
    MapViewController *mvc = (MapViewController *)self.viewController;
    mas.savedExtent = mvc.mapView.visibleArea.envelope;
    
    [super saveAppState];
}

#pragma mark -
#pragma mark App Settings Creation (Overrides)  
-(AppSettings *)createAppSettings
{
    return [[MapAppSettings alloc] init];
}

-(AppSettings *)createAppSettingsWithJSON:(NSDictionary *)JSON
{
    return [[MapAppSettings alloc] initWithJSON:JSON];
}

#pragma mark -
#pragma mark Opening a URL
-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    MapViewController *mvc = (MapViewController *)self.viewController;
        
    //if map is already loaded, go ahead and start the routing mode
    if (mvc.mapLoaded) {
        MapShareUtility *msi = [[MapShareUtility alloc] initWithUrl:url 
                                                withSpatialReference:mvc.mapView.spatialReference 
                                                          locatorURL:[NSURL URLWithString:self.config.locatorServiceUrl]];
        
        [mvc shareInformationWithMap:msi];
    }
    else
    {
        mvc.shareWithMapUrl = url;
    }

    return YES;
}

#pragma mark -
#pragma mark Config Download
-(void) urisOperation:(NSOperation*)op completedWithResults:(NSDictionary*)results
{
    [super urisOperation:op completedWithResults:results];
    
    [self orgOperation:nil didSucceed:nil];
}

#pragma mark -
#pragma mark Organization Download Data
-(void)orgOperation:(AGSJSONRequestOperation *)op didSucceed:(NSDictionary*)json 
{
    NSLog(@"Did Succeed getting org information!");
    
    
    //MapAppSettings *mas = (MapAppSettings *)self.appSettings;
    
    Organization *org = [[Organization alloc] initWithJSON:json];
    org.name = @"Guest";
    org.icon = [UIImage imageNamed:@"Default_icon.png"];
    
    self.testOrganizations = [NSArray arrayWithObjects: org, nil];
    
    MapViewController *mvc = (MapViewController *)self.viewController;
    [mvc chooseFromOrganizations:self.testOrganizations];
    
}

-(void)orgOperation:(AGSJSONRequestOperation*)op didFailWithError:(NSError*)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                   message:@"Could not download organization information" 
                                                  delegate:nil 
                                         cancelButtonTitle:@"OK" 
                                         otherButtonTitles:nil];
    
    [alert show];
}


@end
