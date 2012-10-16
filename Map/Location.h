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
#import "NamedGeometry.h"
#import <ArcGIS/ArcGIS.h>
#import "GeocodeService.h"
#import "ArcGISMobileConfig.h"

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
    
    id<LocationDelegate>        __unsafe_unretained _delegate;
    id<LocationRouteDelegate>   __unsafe_unretained _routeDelegate;
    
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

@property (nonatomic, strong) AGSGeometry                   *geometry;
@property (nonatomic, copy)   NSString                      *name;
@property (nonatomic, strong) UIImage                       *icon;
@property (nonatomic, strong) NSURL                         *locatorUrl;
@property (nonatomic, strong) LocationGraphic               *graphic;

@property (nonatomic, assign) LocationType                  locationType;

@property (nonatomic, strong) AGSAddressCandidate           *addressCandidate;

@property (nonatomic, unsafe_unretained) id<LocationDelegate>          delegate;
@property (nonatomic, unsafe_unretained) id<LocationRouteDelegate>     routeDelegate;

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
