/*
 Copyright © 2013 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

@protocol GeocodeServiceDelegate;
@class GeocodeServiceParameters;
@class ArcGISAppDelegate;

@interface GeocodeService : NSObject <AGSLocatorDelegate, AGSFindTaskDelegate> {
	
    id<GeocodeServiceDelegate>   _delegate;
	NSString                    *_responseString;
    
    AGSLocator                  *_findAddressLocator;
    NSOperation                 *_findAddressOperation;

    NSOperation                 *_findPlaceOperation;
    NSOperation                 *_findLocationOperation;
    
//#warning Just a hack right now to mimic multiple organizations
    NSString                    *_addressLocatorString;
    BOOL                        _useSingleLine;
    
    @private
    
    ArcGISAppDelegate *         _app;
}

@property (nonatomic, strong) id<GeocodeServiceDelegate>    delegate;
@property (nonatomic, strong) NSString                      *responseString;
@property (nonatomic, copy) NSString                        *addressLocatorString;
@property (nonatomic, strong) AGSLocator                    *findAddressLocator;
@property (nonatomic, strong) NSOperation                   *findAddressOperation;
@property (nonatomic, strong) NSOperation                   *findPlaceOperation;
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
// findPOI
//
- (void)geocodeService:(GeocodeService *)geocodeService operation:(NSOperation*)op didFindPOI:(NSArray *)places;
- (void)geocodeService:(GeocodeService *)geocodeService operation:(NSOperation*)op didFailFindPOI:(NSError *)error;

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
@property (nonatomic, strong) NSNumber *score;
@property (nonatomic, strong) AGSPoint *location;
@property (nonatomic, strong) AGSEnvelope *extent;

@end

@interface FindPOI : NSObject <AGSCoding>{
	NSString *_name;
	NSNumber *_score;
    AGSPoint *_location;
    AGSEnvelope *_extent;
}

-(id)initWithJSON:(NSDictionary *)json withSpatialReference:(AGSSpatialReference *)spatialReference;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSNumber *score;
@property (nonatomic, strong) AGSPoint *location;
@property (nonatomic, strong) AGSEnvelope *extent;

@end