//
//  GeocodeService.m
//  ArcGISMobile
//
//  Created by Mark Dostal on 6/14/11.
/*
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

#import "GeocodeService.h"

#import "MapAppDelegate.h"
#import "ArcGISMobileConfig.h"
#import "NSDictionary+Additions.h"

@interface GeocodeService ()

@property (nonatomic, unsafe_unretained) ArcGISAppDelegate *app;

@end

@implementation GeocodeService

@synthesize delegate = _delegate;
@synthesize responseString = _responseString;
@synthesize findAddressLocator = _findAddressLocator;
@synthesize addressLocatorString = _addressLocatorString;
@synthesize findAddressOperation = _findAddressOperation;
@synthesize findPlaceOperation = _findPlaceOperation;
@synthesize useSingleLine = _useSingleLine;


//private properties
@synthesize app = _app;

#pragma mark -
#pragma mark NSURLConnection

#pragma mark -
#pragma mark Public


#pragma -
#pragma mark Lazy Loads
-(ArcGISAppDelegate *)app
{
    if(_app == nil)
        self.app = (ArcGISAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    return _app;
}

#pragma mark -
#pragma mark findAddressCandidates

- (NSOperation *)findAddressCandidates:(NSString *)searchString withSpatialReference:(AGSSpatialReference *)spatialReference {
	
    if (self.findAddressOperation)
    {
        //if we're already finding an address, cancel it
        [self.findAddressOperation cancel];
    }
    
    
    // Searching first with the new Geocoder at
#warning needs to be replace when the new ArcGIS Runtime SDK is available.
    // This is a work around until the new ArcGIS Runtime for iOS is available with a class
    // that supports passing an extent for searching.
//    if ( self.app.config.geocoderServiceUrlNew != nil ) {
//        
//        MapAppDelegate *appDelegate = (MapAppDelegate *)[[UIApplication sharedApplication] delegate];
//    
//        AGSGeometryEngine *geoEngine = [AGSGeometryEngine defaultGeometryEngine];
//        AGSEnvelope *wgsEnvelope = (AGSEnvelope*)[geoEngine projectGeometry:appDelegate.mapView.visibleArea.envelope toSpatialReference:[AGSSpatialReference spatialReferenceWithWKID:4326]];
//        
//        NSMutableString *bbox = [[NSMutableString alloc] initWithFormat:@"%f,%f,%f,%f", wgsEnvelope.xmin,
//        wgsEnvelope.ymin,wgsEnvelope.xmax,wgsEnvelope.ymax ];
//        
//        [bbox replaceOccurrencesOfString:@","
//                                    withString:@"%2C"
//                                    options:0
//                                    range:NSMakeRange(0, [bbox length])];
//        
//        NSMutableString *cleanSearchString = [[NSMutableString alloc] initWithString:searchString];
//        [cleanSearchString replaceOccurrencesOfString:@" "
//                                           withString:@"+"
//                                              options:0
//                                                range:NSMakeRange(0, [cleanSearchString length])];
//        
//        NSMutableString *requestString = [[NSMutableString alloc] initWithString:self.app.config.geocoderServiceUrlNew];
//        [requestString appendFormat:@"/find?Text=%@", cleanSearchString];
//        //&outFields=&outSR=&bbox=&f=pjson
//        [requestString appendFormat:@"&outFields=&outSR=%d&bbox=%@&f=pjson", appDelegate.mapView.spatialReference.wkid ,bbox];
//        
//        // Replace with AGSJSONRequestOperation
//        AGSJSONRequestOperation *requestOp = [[AGSJSONRequestOperation alloc]initWithURL:[NSURL URLWithString:requestString]];
//        requestOp.target = self;
//        requestOp.action = @selector(requestOp:completedWithResultsGeocoder:);
//        //requestOp.errorAction = @selector(urisOperation:didFailWithError:);
//        [[AGSRequestOperation sharedOperationQueue] addOperation:requestOp];
//        
//    }
    

    // Search for address using AddressLocator (AGSLocator)
    if(!self.findAddressLocator)
    {
        NSURL *url = ( self.addressLocatorString != nil && self.addressLocatorString.length > 0) ?  [NSURL URLWithString:self.addressLocatorString] : 
                                                                                                    [NSURL URLWithString:self.app.config.locatorServiceUrl];
        self.findAddressLocator = [AGSLocator locatorWithURL:url];
        self.findAddressLocator.delegate = self;
    }

    NSString *currentLocaleString = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:searchString, (self.useSingleLine) ? @"SingleLine" : @"SingleKey",
                            currentLocaleString, @"localeCode", nil];  
    
    self.findAddressOperation = [self.findAddressLocator locationsForAddress:params
                                                                returnFields:[NSArray arrayWithObject:@"*"]
                                                         outSpatialReference:spatialReference];
    
    return (self.findAddressOperation);
}

#pragma mark -
#pragma Geocoder returns
-(void) requestOp:(NSOperation*)op completedWithResultsGeocoder:(NSDictionary*)results
{
    NSLog(@"Results: %@", results);
    
    NSArray *jsonArray = [results valueForKey:@"locations"];
    NSMutableArray *places = [NSMutableArray arrayWithCapacity:[jsonArray count]];
    
    MapAppDelegate *appDelegate = (MapAppDelegate *)[[UIApplication sharedApplication] delegate];
    AGSSpatialReference *spatialReference = appDelegate.mapView.spatialReference;
    
    for (NSDictionary *placeJson in jsonArray) {
        
        FindPlaceCandidate *place = [[FindPlaceCandidate alloc] initWithJSON:placeJson withSpatialReference:spatialReference];
        [places addObject:place];
        
    }
    
    [self.delegate geocodeService:self operation:op didFindPlace:places];
}

// Locator delegate methods
- (void) locator:(AGSLocator *)locator operation:(NSOperation *)op didFindLocationsForAddress:(NSArray *)candidates
{
    NSLog(@"%@ Found %d candidates",locator.URL ,[candidates count] );
    
    if ([self.delegate respondsToSelector:@selector(geocodeService:operation:didFindLocationsForAddress:)])
    {
        [self.delegate geocodeService:self operation:op didFindLocationsForAddress:candidates];
    }    
    
    self.findAddressOperation = nil;
}

- (void) locator: (AGSLocator *) locator operation: (NSOperation *) op didFailLocationsForAddress: (NSError *) error
{
	NSLog(@"%@", error);
    
    if ([self.delegate respondsToSelector:@selector(geocodeService:operation:didFailLocationsForAddress:)])
    {
        [self.delegate geocodeService:self operation:op didFailLocationsForAddress:error];
    }
    
    self.findAddressOperation = nil;
}

#pragma mark -
#pragma mark findPlace

- (NSOperation *)findPlace:(NSString *)searchString withSpatialReference:(AGSSpatialReference *)spatialReference {
	
    if (self.findPlaceOperation)
    {
        //if we're already finding an address, cancel it
        [self.findPlaceOperation cancel];
        self.findPlaceOperation = nil;
    }
    
    NSString *currentLocaleString = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"json", @"f",
                                   searchString, @"place",
                                   currentLocaleString, @"localeCode",
                                   nil];
            
    if (spatialReference != nil){
        [spatialReference encodeToJSON:params forKey:@"outSR"];
    }

    NSURL *url = [NSURL URLWithString:self.app.config.worldLocatorServiceUrl];

    AGSJSONRequestOperation *operation = [[AGSJSONRequestOperation alloc] initWithURL:url
                                                                             resource:@"findPlace"
                                                                      queryParameters:params
                                                                               doPOST:YES];
    
    operation.target = self;
    operation.action = @selector(findPlaceOperation:didComplete:);
    operation.errorAction = @selector(findPlaceOperation:didFailWithError:);
    operation.credential = nil;
    
    [[AGSRequestOperation sharedOperationQueue] addOperation:operation];
    
    self.findPlaceOperation = operation;
    
    return operation;
}

- (void)findPlaceOperation:(NSOperation*)op didComplete:(NSDictionary *)json {

    AGSSpatialReference *spatialReference = nil;

    id tmp = [json valueForKey:@"spatialReference"];    
    if (tmp && tmp != [NSNull null])
    {
        spatialReference = [[AGSSpatialReference alloc] initWithJSON:tmp]; 
    }
    
    NSArray *jsonArray = [json valueForKey:@"candidates"];
    NSMutableArray *places = [NSMutableArray arrayWithCapacity:[jsonArray count]];
    for (NSDictionary *placeJson in jsonArray) {
        
        FindPlaceCandidate *place = [[FindPlaceCandidate alloc] initWithJSON:placeJson withSpatialReference:spatialReference];
        [places addObject:place];
        
    }
    
    if ([self.delegate respondsToSelector:@selector(geocodeService:operation:didFindPlace:)])
    {
        [self.delegate geocodeService:self operation:op didFindPlace:places];
    }
}

- (void)findPlaceOperation:(NSOperation *)op didFailWithError:(NSError *)error {

    if ([self.delegate respondsToSelector:@selector(geocodeService:operation:didFailFindPlace:)])
    {
        [self.delegate geocodeService:self operation:op didFailFindPlace:error];
    }
}

#pragma mark -
#pragma mark Find Results
- (void)findTask:(AGSFindTask *)findTask operation:(NSOperation*)op didExecuteWithFindResults:(NSArray *)results
{
    NSLog(@"Find results %@", results);
}

#pragma mark -
#pragma mark Memory Management

-(void) dealloc{
	self.delegate = nil;
}

@end

#pragma mark -
#pragma mark FindPlaceCandidate

@implementation FindPlaceCandidate

@synthesize name = _name;
@synthesize score = _score;
@synthesize location = _location;
@synthesize extent = _extent;


-(id)initWithJSON:(NSDictionary *)json withSpatialReference:(AGSSpatialReference *)spatialReference
{
    if (self = [self initWithJSON:json])
    {
        //use the spatialReference with our location
        self.location = [AGSPoint pointWithX:self.location.x y:self.location.y spatialReference:spatialReference];
        self.extent = [AGSEnvelope envelopeWithXmin:self.extent.xmin
                                               ymin:self.extent.ymin
                                               xmax:self.extent.xmax
                                               ymax:self.extent.ymax
                                   spatialReference:spatialReference];
    }
    
    return self;
}

- (id)initWithJSON:(NSDictionary *)json {
    if (self = [super init]) {
        [self decodeWithJSON:json];
    }
    
    return self;
}

- (NSDictionary*)encodeToJSON {
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
    [NSDictionary safeSetObjectInDictionary:dict object:self.name withKey:@"name"];
    [NSDictionary safeSetObjectInDictionary:dict object:self.score withKey:@"score"];
	[dict setValue:[self.location encodeToJSON] forKey:@"location"];
	[dict setValue:[self.extent encodeToJSON] forKey:@"extent"];
	
	return dict;
}

- (void)decodeWithJSON:(NSDictionary *)json {
    self.name = [json valueForKey:@"name"];
    self.score = [json valueForKey:@"score"];
    self.location = [[AGSPoint alloc] initWithJSON:[json valueForKey:@"location"]];
    self.extent = [[AGSEnvelope alloc] initWithJSON:[json valueForKey:@"extent"]];
}



@end
