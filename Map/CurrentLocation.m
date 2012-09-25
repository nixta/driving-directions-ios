//
//  CurrentLocation.m
//  Map
//
//  Created by Scott Sirowy on 9/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CurrentLocation.h"
#import "ArcGIS+App.h"

@interface CurrentLocation () 

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation CurrentLocation

@synthesize locationManager = _locationManager;

#pragma mark -
#pragma mark Cleanup
-(void)dealloc
{
    self.locationManager.delegate = nil;
}

#pragma mark -
#pragma mark Init Methods

- (id)init
{
    return [self initWithIcon:nil locatorURL:nil];
}

-(id)initWithIcon:(UIImage *)icon locatorURL:(NSURL *)url
{
    return [self initWithName:NSLocalizedString(@"Current Location", nil) 
                       anIcon:icon 
                   locatorURL:url];
}

#pragma mark -
#pragma mark Overrides

//update address everytime user wants to show
-(BOOL)hasAddress
{
    [self invalidateAddress];
    return [super hasAddress];
}

//always force current locationt to update point 
-(BOOL)hasValidPoint
{
    self.geometry = nil;
    return [super hasValidPoint];
}

-(void)updatePoint
{
    if(_updatingPoint)
        return;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    [self.locationManager startUpdatingLocation];
}

#pragma mark -
#pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    AGSPoint *newCurrentLocationInWGS84 = [AGSPoint pointWithX:newLocation.coordinate.longitude 
                                                             y:newLocation.coordinate.latitude 
                                              spatialReference:[AGSSpatialReference wgs84SpatialReference]];
    
    
    //reproject to map spatial reference
    AGSGeometryEngine *ge = [AGSGeometryEngine defaultGeometryEngine];
    self.geometry = (AGSPoint *)[ge projectGeometry:newCurrentLocationInWGS84 
                                 toSpatialReference:[AGSSpatialReference webMercatorSpatialReference]];
    
    //kill location manager until they call update point again
    _updatingPoint = NO;
    [self.locationManager stopUpdatingLocation];
    self.locationManager = nil;
    
    if([self.delegate respondsToSelector:@selector(location:updatedPoint:)])
    {
        [self.delegate location:self updatedPoint:(AGSPoint *)self.geometry];
    }
}

#pragma mark -
#pragma mark Class Methods
+(CurrentLocation *)aCurrentLocationWithLocatorURL:(NSURL *)url;
{
    //Simulator has problems with GPS... use a pseudo-current location pointed at ESRI for now
#if (TARGET_IPHONE_SIMULATOR)
    AGSSpatialReference *sr = [AGSSpatialReference webMercatorSpatialReference];
    AGSPoint *esriPoint = [AGSPoint pointWithX:-13046166.549800 y:4036562.568769 spatialReference:sr];
    
    SimulatedCurrentLocation *esriLocation = [[SimulatedCurrentLocation alloc] initWithPoint:esriPoint 
                                                        aName:@"  Current Location" 
                                                       anIcon:[UIImage imageNamed:@"ArcGIS.bundle/GpsDisplay.png"]
                                                   locatorURL:url];
    return esriLocation;
#else
    return [[CurrentLocation alloc] initWithIcon:[UIImage imageNamed:@"AddressPin.png"] 
                                       locatorURL:url];
#endif
}

@end

@implementation SimulatedCurrentLocation

-(BOOL)hasValidPoint
{
    //simulated current location should be initialized with an actual location for this to actually work...
    return YES;
}


@end
