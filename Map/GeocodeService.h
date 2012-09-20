//
//  GeocodeService.h
//  ArcGISMobile
//
//  Created by Mark Dostal on 6/14/11.
//  Copyright 2011 ESRI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ArcGIS+App.h"

@protocol GeocodeServiceDelegate;
@class GeocodeServiceParameters;
@class ArcGISAppDelegate;

@interface GeocodeService : NSObject <AGSLocatorDelegate> {
	
    id<GeocodeServiceDelegate>  _delegate;
	NSString                    *_responseString;
    
    AGSLocator                  *_findAddressLocator;
    NSOperation                 *_findAddressOperation;

    NSOperation                 *_findPlaceOperation;
    NSOperation                 *_findLocationOperation;
    
//#warning Just a hack right now to mimic multiple organizations
    NSString                    *_addressLocatorString;
    BOOL                        _useSingleLine;
    
    @private
    
    ArcGISAppDelegate *_app;
}

@property (nonatomic, assign) id<GeocodeServiceDelegate>    delegate;
@property (nonatomic, retain) NSString                      *responseString;
@property (nonatomic, copy) NSString                        *addressLocatorString;
@property (nonatomic, retain) AGSLocator                    *findAddressLocator;
@property (nonatomic, retain) NSOperation                   *findAddressOperation;
@property (nonatomic, retain) NSOperation                   *findPlaceOperation;
@property (nonatomic, assign) BOOL                          useSingleLine;

- (NSOperation *)findAddressCandidates:(NSString *)searchString withSpatialReference:(AGSSpatialReference *)spatialReference;
- (NSOperation *)findPlace:(NSString *)searchString withSpatialReference:(AGSSpatialReference *)spatialReference;

//- (NSOperation *)reverseAddressMatch:(AGSPoint *)location maxSearchDistance:(double)distance withSpatialReference:(AGSSpatialReference *)spatialReference;

@end

#pragma mark _
#pragma mark GeocodeServiceDelegate

@protocol GeocodeServiceDelegate <NSObject>

@optional

//
//findAddressCandidates
//
- (void)geocodeService:(GeocodeService *)geocodeService operation:(NSOperation*)op didFindLocationsForAddress:(NSArray *)places;
- (void)geocodeService:(GeocodeService *)geocodeService operation:(NSOperation*)op didFailLocationsForAddress:(NSError *)error;

//
//findPlace
//
- (void)geocodeService:(GeocodeService *)geocodeService operation:(NSOperation*)op didFindPlace:(NSArray *)places;
- (void)geocodeService:(GeocodeService *)geocodeService operation:(NSOperation*)op didFailFindPlace:(NSError *)error;

//
//reverseAddressMatch
//
//- (void)geocodeService:(GeocodeService *)geocodeService operation:(NSOperation*)op didFindAddressForLocation:(AGSAddressCandidate *)candidates;
//- (void)geocodeService:(GeocodeService *)geocodeService operation:(NSOperation*)op didFailAddressForLocation:(NSError *)error;

@end

#pragma mark _
#pragma mark GeocodeServiceResult

@interface FindPlaceCandidate : NSObject <AGSCoding>{
	NSString *_name;
	NSNumber *_score;
    AGSPoint *_location;
    AGSEnvelope *_extent;
}

-(id)initWithJSON:(NSDictionary *)json withSpatialReference:(AGSSpatialReference *)spatialReference;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, retain) NSNumber *score;
@property (nonatomic, retain) AGSPoint *location;
@property (nonatomic, retain) AGSEnvelope *extent;

@end