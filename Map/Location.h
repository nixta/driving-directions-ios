//
//  Location.h
//  Map
//
//  Created by Scott Sirowy on 9/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NamedGeometry.h"
#import "ArcGIS+App.h"
#import "GeocodeService.h"

@protocol LocationDelegate;
@protocol LocationRouteDelegate;
@class LocationGraphic;

/*
 A Location conforms to the NamedGeometry protocol. A location is essentially
 a wrapper for an AGSPoint that also knows how to geocode and/or reverse geocode
 itself.
 
 A location tells interestd objects that its address or point have been update via
 the LocationDelegate protocol and the notification system
 */

typedef enum
{
    LocationTypeNone = 0,
    LocationTypeStartLocation = 1,
    LocationTypeTransitLocation = 2,
    LocationTypeDestinationLocation = 3,
} LocationType;

@interface Location : NSObject <NamedGeometry, AGSLocatorDelegate, GeocodeServiceDelegate, AGSCoding, NSCopying>
{
    AGSGeometry                 *_geometry;
    NSString                    *_name;
    UIImage                     *_icon;
    NSURL                       *_locatorUrl;
    
    AGSAddressCandidate         *_addressCandidate;
    
    id<LocationDelegate>        _delegate;
    id<LocationRouteDelegate>   _routeDelegate;
    
    LocationGraphic             *_graphic;
    
    LocationType                _locationType;
    
    @private
    UIImage                     *_defaultIcon;
    NSOperation                 *_locatorOperation;
    AGSLocator                  *_locator;
    
    GeocodeService              *_geocodeService;
    AGSAddressCandidate         *_updateAddressCandidate;
    FindPlaceCandidate          *_findPlaceCandidate;
    BOOL                        _finishedFindAddress;
    BOOL                        _finishedFindPlace;
}

@property (nonatomic, retain) AGSGeometry                   *geometry;
@property (nonatomic, copy)   NSString                      *name;
@property (nonatomic, retain) UIImage                       *icon;
@property (nonatomic, retain) NSURL                         *locatorUrl;
@property (nonatomic, retain) LocationGraphic               *graphic;

@property (nonatomic, assign) LocationType                  locationType;

@property (nonatomic, retain) AGSAddressCandidate           *addressCandidate;

@property (nonatomic, assign) id<LocationDelegate>          delegate;
@property (nonatomic, assign) id<LocationRouteDelegate>     routeDelegate;

/*Use this when you don't necessarily have an actual point, but rather an address or place name */
-(id)initWithName:(NSString *)name anIcon:(UIImage *)icon locatorURL:(NSURL *)url;

/*Default initializer */
-(id)initWithPoint:(AGSPoint *)locationPoint aName:(NSString *)name anIcon:(UIImage *)icon locatorURL:(NSURL *)url;

-(BOOL)hasAddress;
-(void)updateAddress;
-(void)invalidateAddress;

-(NSString *)searchString;

-(BOOL)hasValidPoint;
-(void)updatePoint;

-(AGSPoint *)locationPoint;
-(NSString *)addressString;

-(void)updateSymbol;

/*Returns a url string for location that can be passed to other apps */
-(NSString *)urlStringWithUrlScheme:(NSString *)scheme;

@end

@protocol LocationDelegate <NSObject>

@optional

-(void)location:(Location *)loc updatedPoint:(AGSPoint *)point;
-(void)locationFailedToAttainNewPoint:(Location *)location;

@end

@protocol LocationRouteDelegate <NSObject>

-(NSUInteger)transitIndexForLocation:(Location *)location;

@end
