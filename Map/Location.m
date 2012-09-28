//
//  Location.m
//  Map
//
//  Created by Scott Sirowy on 9/6/11.
/*
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

#import "Location.h"
#import "LocationGraphic.h"
#import "NSDictionary+Additions.h"
#import "AGSSymbol+AppAdditions.h"

#import "MapAppDelegate.h"
#import "MapAppSettings.h"
#import "Organization.h"
#import "MapStates.h"



#define kAddressDistance 50

@interface Location () 

@property (nonatomic, strong) NSOperation           *locatorOperation;
@property (nonatomic, strong) AGSLocator            *locator;

@property (nonatomic, strong) GeocodeService        *geocodeService;
@property (nonatomic, strong) AGSAddressCandidate   *updateAddressCandidate;
@property (nonatomic, strong) FindPlaceCandidate    *findPlaceCandidate;
@property (nonatomic, strong) UIImage               *defaultIcon;

-(void)finishUpdatePoint;
-(AGSSymbol *)symbolForGraphic;

@end

@implementation Location

@synthesize geometry                = _geometry;
@synthesize name                    = _name;
@synthesize icon                    = _icon;
@synthesize locatorUrl              = _locatorUrl;
@synthesize graphic                 = _graphic;
@synthesize locationType            = _locationType;

@synthesize locatorOperation        = _locatorOperation;
@synthesize locator                 = _locator;

@synthesize geocodeService          = _geocodeService;
@synthesize updateAddressCandidate  = _updateAddressCandidate;
@synthesize findPlaceCandidate      = _findPlaceCandidate;
@synthesize defaultIcon             = _defaultIcon;

@synthesize addressCandidate        = _addressCandidate;

@synthesize delegate                = _delegate;
@synthesize routeDelegate           = _routeDelegate;


- (id)init
{
    return [self initWithPoint:nil aName:nil anIcon:nil locatorURL:nil];
}

//can call this when user doesn't have a point, but maybe just an address
-(id)initWithName:(NSString *)name anIcon:(UIImage *)icon locatorURL:(NSURL *)url
{
    return [self initWithPoint:nil aName:name anIcon:icon locatorURL:url];
}

//Default initializer
-(id)initWithPoint:(AGSPoint *)locationPoint aName:(NSString *)name anIcon:(UIImage *)icon locatorURL:(NSURL *)url
{
    self = [super init];
    if(self)
    {
        self.locationType = LocationTypeNone;
        
        //default icon needs to be set first since through the magic of lazy loads
        self.defaultIcon = icon;
        self.geometry = locationPoint;
        self.name = name;
        self.locatorUrl = url;
    }
    
    return self;
}

-(BOOL)hasAddress
{
    return (self.addressCandidate != nil);
}

-(void)invalidateAddress
{
    [self.locatorOperation cancel];
    self.addressCandidate = nil;
}

-(void)updateAddress
{
    [self.locatorOperation cancel];
    self.locatorOperation = [self.locator addressForLocation:(AGSPoint *)self.geometry 
                                           maxSearchDistance:kAddressDistance];
}

//string used to search for addresses and places. By default use the location's name
-(NSString *)searchString
{
    //use the name if we have one
    if (self.name && self.name.length > 0)
        return self.name;
    
    if ([self hasAddress])
        return [self addressString];
    
    //last resort... pass back coordinates 
    AGSPoint *wgs84Point = (AGSPoint *)[[AGSGeometryEngine defaultGeometryEngine] projectGeometry:self.geometry 
                                                                               toSpatialReference:[AGSSpatialReference wgs84SpatialReference]];
    
    return [NSString stringWithFormat:@"%.5f %.5f", wgs84Point.x, wgs84Point.y];
}

-(BOOL)hasValidPoint
{
    return (self.geometry != nil);
}

-(void)updatePoint
{    
    if (!self.geocodeService)
    {
        MapAppDelegate *app = (MapAppDelegate *)[[UIApplication sharedApplication] delegate];
        MapAppSettings *settings = (MapAppSettings *)app.appSettings;
        
        self.geocodeService = [[GeocodeService alloc] init];
        self.geocodeService.delegate = self;

        self.geocodeService.addressLocatorString = settings.organization.locatorUrlString;
        self.geocodeService.useSingleLine = (settings.organization.locatorUrlString == nil);
    }
    
    //set flags
    _finishedFindAddress = NO;
    _finishedFindPlace = NO;
    
    //Using a default spatial reference right now... Needs to match map
    [self.geocodeService findAddressCandidates:[self searchString] withSpatialReference:[AGSSpatialReference webMercatorSpatialReference]];
    [self.geocodeService findPlace:self.name withSpatialReference:[AGSSpatialReference webMercatorSpatialReference]];
}

-(AGSPoint *)locationPoint
{
    return (AGSPoint *)self.geometry;
}

-(NSString *)addressString
{
    //will not return a string if 
    if(![self hasAddress])
        return nil;
    
    NSString *addressString = nil;
    
    //if non-nil, we have a real address
    if (self.addressCandidate)
    {
        id addressField = [self.addressCandidate.address objectForKey:@"Address"];
        NSString *defaultString = self.addressCandidate.addressString;
        
        if (defaultString && defaultString.length != 0)
        {
            addressString = defaultString;
        }
        else if (addressField && addressField != [NSNull null])
        {
            addressString = (NSString *)addressField;
        }
        else
        {
            //assembly string from candidate address dictionary
            id houseNumberField = [self.addressCandidate.address objectForKey:@"HouseNumber"];
            id streetField = [self.addressCandidate.address objectForKey:@"Street"];
            id cityField = [self.addressCandidate.address objectForKey:@"City"];
            id stateField = [self.addressCandidate.address objectForKey:@"State"];
            id zipField = [self.addressCandidate.address objectForKey:@"PostalCode"];
            id countryField = [self.addressCandidate.address objectForKey:@"Country"];
            
            BOOL bAddComma = NO;
            BOOL bAddSpace = NO;
            
            //reset
            addressString = @"";
            if (houseNumberField != nil && houseNumberField != [NSNull null])
            {
                //add the house number and a space
                addressString = [addressString stringByAppendingFormat:@"%@ ", houseNumberField];
            }
            if (streetField != nil && streetField != [NSNull null])
            {
                addressString = [addressString stringByAppendingFormat:@"%@", streetField];
                bAddComma = YES;
            }
            if (cityField != nil && cityField != [NSNull null])
            {
                addressString = [addressString stringByAppendingFormat:@"%@%@", (bAddComma ? @", " : @""), cityField];
                bAddComma = YES;
            }
            if (stateField != nil && stateField != [NSNull null])
            {
                addressString = [addressString stringByAppendingFormat:@"%@%@", (bAddComma ? @", " : @""), stateField];
                bAddSpace = YES;
            }
            if (zipField != nil && zipField != [NSNull null])
            {
                //no comma, just a space between state and Zip
                addressString = [addressString stringByAppendingFormat:@"%@%@", (bAddSpace ? @" " : @""), zipField];
                bAddSpace = YES;
            }            
            if (countryField != nil && countryField != [NSNull null])
            {
                //no comma, just a space between state and Zip
                addressString = [addressString stringByAppendingFormat:@"%@%@", (bAddSpace ? @" " : @""), countryField];
            }            
        }
    }
    
    return addressString;
}

/*Returns a url string for location that can be passed to other apps */
-(NSString *)urlStringWithUrlScheme:(NSString *)scheme
{
#warning Fill me in!
    return @"Test String";
}

-(LocationGraphic *)graphic
{
    if(_graphic == nil)
    {        
        self.graphic =   [LocationGraphic graphicWithGeometry:self.geometry 
                                                       symbol:[self symbolForGraphic] 
                                                   attributes:nil 
                                         infoTemplateDelegate:nil]; 
        
        _graphic.location = self;
    }
    
    return _graphic;
}

-(void)updateSymbol
{
    //update symbol for graphic and update graphic on map if necessary
    self.graphic.symbol = [self symbolForGraphic];
    if (self.graphic.layer != nil) {
        [self.graphic.layer dataChanged];
    }
}

#pragma mark -
#pragma mark Lazy Load
-(AGSLocator *) locator{
	if (_locator == nil){
		AGSLocator *agsLocator = [AGSLocator locatorWithURL:self.locatorUrl];
        
        agsLocator.delegate = self;
		self.locator = agsLocator;
	}
	return _locator;
}

//Custom getter...
-(UIImage *)icon
{
    if (self.locationType == LocationTypeNone)
        return self.defaultIcon;
 
    //normalize symbol so it shows up as (0,0)
    AGSSymbol *normalizedSymbol = [self.graphic.symbol normalize];
    UIImage *swatch = [normalizedSymbol swatchForGeometryType:AGSGeometryTypePoint size:CGSizeMake(40, 40)];
    return swatch;
}

#pragma mark -
#pragma mark Custom Setter
-(void)setIcon:(UIImage *)icon
{
    self.defaultIcon = icon;
    
    [self updateSymbol];
}

-(void)setLocationType:(LocationType)locationType
{
    //if it's the same type, no need to update symbol... unless its a transit,
    //in which case we should update symbol regardless
    if (self.locationType == locationType && locationType != LocationTypeTransitLocation)
        return;
    
    _locationType = locationType;
    
    [self updateSymbol];
}

-(void)setGeometry:(AGSGeometry *)geometry
{
    _geometry = geometry;
    
    self.graphic.geometry = _geometry;
    if(self.graphic.layer != nil)
        [self.graphic.layer dataChanged];
} 

#pragma mark -
#pragma mark AGSLocatorDelegate

- (void)locator:(AGSLocator *)locator operation:(NSOperation*)op didFindAddressForLocation:(AGSAddressCandidate *)candidate
{	
    self.locatorOperation = nil;
    self.addressCandidate = candidate;
        
    [[NSNotificationCenter defaultCenter] postNotificationName:kLocationUpdatedAddress object:self];
}

/** Tells the delegate that @c %AGSLocator encountered an error while finding an address candidate
 @param locator called to find address candidates
 @param error returned by the service
 @since 1.0
 */
- (void)locator:(AGSLocator *)locator operation:(NSOperation*)op didFailAddressForLocation:(NSError *)error
{
    self.locatorOperation = nil;
        
    [[NSNotificationCenter defaultCenter] postNotificationName:kLocationFailedToUpdateAddress object:self];
}

#pragma mark GeocodeServiceDelegate

- (void)geocodeService:(GeocodeService *)geocodeService operation:(NSOperation*)op didFindLocationsForAddress:(NSArray *)candidates;
{
	if (candidates != nil && [candidates count] > 0)
	{	
        //take the highest scoring candidate and save for later
        self.updateAddressCandidate = (AGSAddressCandidate *)[candidates objectAtIndex:0];
	}
    
    _finishedFindAddress = YES;
    [self performSelector:@selector(finishUpdatePoint) withObject:nil afterDelay:0.0];
}

- (void)geocodeService:(GeocodeService *)geocodeService operation:(NSOperation*)op didFailLocationsForAddress:(NSError *)error
{
    self.updateAddressCandidate = nil;
    _finishedFindAddress = YES;
    [self performSelector:@selector(finishUpdatePoint) withObject:nil afterDelay:0.0];
}

- (void)geocodeService:(GeocodeService *)geocodeService operation:(NSOperation*)op didFindPlace:(NSArray *)places
{
	if (places != nil && [places count] > 0)
	{
        //take the highest scoring candidate and save for later
        self.findPlaceCandidate = (FindPlaceCandidate *)[places objectAtIndex:0];
	}
    
    _finishedFindPlace  = YES;
    [self performSelector:@selector(finishUpdatePoint) withObject:nil afterDelay:0.0];
}

- (void)geocodeService:(GeocodeService *)geocodeService operation:(NSOperation*)op didFailFindPlace:(NSError *)error
{
    self.findPlaceCandidate = nil;
    _finishedFindPlace  = YES;
   [self performSelector:@selector(finishUpdatePoint) withObject:nil afterDelay:0.0];
}

-(void)finishUpdatePoint
{
    //if we haven't finished both, return immediately
    if (!_finishedFindAddress || !_finishedFindPlace)
        return;
    
    //couldn't attain a point at all. Warn delegate location failed
    if (self.updateAddressCandidate == nil && self.findPlaceCandidate == nil) {
        if ([self.delegate respondsToSelector:@selector(locationFailedToAttainNewPoint:)]) {
            [self.delegate locationFailedToAttainNewPoint:self];
        }
        
        self.geometry = nil;
        return;
    }
    
    //have at least one valid location to pick from. Pick the best one...
    
    //pick the best scoring location and use that as our location
    if (self.updateAddressCandidate.score >= [self.findPlaceCandidate.score intValue]) {
        self.geometry = [self.updateAddressCandidate.location mutableCopy];
    }
    else
    {
        self.name = self.findPlaceCandidate.name;
        self.geometry = [self.findPlaceCandidate.location mutableCopy];
    }
    
    //get rid of all geocode service related items
    self.geocodeService = nil;
    self.updateAddressCandidate = nil;
    self.findPlaceCandidate = nil;
    _finishedFindPlace = NO;
    _finishedFindAddress = NO;
    
    //tell delegate point has been attained
    if ([self.delegate respondsToSelector:@selector(location:updatedPoint:)]) {
        [self.delegate location:self updatedPoint:(AGSPoint *)self.geometry];
    }
}

#pragma mark -
#pragma mark Private Methods
-(AGSSymbol *)symbolForGraphic
{
    AGSPictureMarkerSymbol *locationSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImage:self.defaultIcon];
    locationSymbol.xoffset = 9;
    locationSymbol.yoffset = 16;
    locationSymbol.hotspot = CGPointMake(-9, 11);
    
    if(self.locationType == LocationTypeNone)
        return locationSymbol;
    
    //have to create a custom location symbol 
    AGSCompositeSymbol *cs = [AGSCompositeSymbol compositeSymbol];
    
    [cs.symbols addObject:locationSymbol];
    
    AGSSimpleMarkerSymbol *circleMarkerSymbol = [AGSSimpleMarkerSymbol simpleMarkerSymbol];
    circleMarkerSymbol.style = AGSSimpleMarkerSymbolStyleCircle;
    circleMarkerSymbol.size = 18;
    circleMarkerSymbol.xoffset = 12;
    circleMarkerSymbol.yoffset = 25;
    
    switch (self.locationType) {
        case LocationTypeStartLocation:
            circleMarkerSymbol.color = [UIColor greenColor];
            break;
        case LocationTypeDestinationLocation:
            circleMarkerSymbol.color = [UIColor redColor];
            break;
        case LocationTypeTransitLocation:
            circleMarkerSymbol.color = [UIColor yellowColor];
        default:
            break;
    }
    
    [cs.symbols addObject:circleMarkerSymbol];
    
    if (self.locationType == LocationTypeTransitLocation) {
        
        NSUInteger stopNumber = NSNotFound;
        if([self.routeDelegate respondsToSelector:@selector(transitIndexForLocation:)])
        {
            stopNumber = [self.routeDelegate transitIndexForLocation:self];
        }
        
        NSString *stopString = @"";
        if (stopNumber != NSNotFound) {
            stopString = [NSString stringWithFormat:@"%d", stopNumber];
        }
        
        AGSTextSymbol *ts = [AGSTextSymbol textSymbolWithTextTemplate:stopString color:[UIColor blackColor]];
        ts.xoffset = 9;
        ts.yoffset = 21;
        [cs.symbols addObject:ts];
    }
    
    return cs;
}

#pragma mark -
#pragma mark AGSCoding

-(id)initWithJSON:(NSDictionary *)json
{
    self = [self init];
    if(self)
    {
        [self decodeWithJSON:json];
    }
    
    return self;
}

- (void)decodeWithJSON:(NSDictionary *)json
{
    NSDictionary *geomJSON = [json objectForKey:@"geometry"];
    if(geomJSON)
    {
        self.geometry = [[AGSPoint alloc] initWithJSON:geomJSON];
    }
    
    self.name = [AGSJSONUtility getStringFromDictionary:json withKey:@"name"];
    
    NSString *base64IconString = [NSDictionary safeGetObjectFromDictionary:json withKey:@"icon"];
    if (base64IconString) {
        NSData *iconData = [AGSBase64 decode:base64IconString];
        self.icon = [UIImage imageWithData:iconData];
    }
    
    NSString *urlString = [AGSJSONUtility getStringFromDictionary:json withKey:@"locatorUrl"];
    if (urlString && urlString.length > 0) {
        self.locatorUrl = [NSURL URLWithString:urlString];
    }
}

- (NSDictionary *)encodeToJSON
{
    NSMutableDictionary *json = [NSMutableDictionary dictionaryWithCapacity:3];
    
    [json setObject:[self.geometry encodeToJSON] forKey:@"geometry"];
    [NSDictionary safeSetObjectInDictionary:json object:self.name withKey:@"name"];
    
    NSData *iconData = UIImagePNGRepresentation(self.icon);
    NSString *base64Icon = [AGSBase64 encode:iconData];
    [NSDictionary safeSetObjectInDictionary:json object:base64Icon withKey:@"icon"];
    
    NSString *locatorUrlString = [self.locatorUrl absoluteString];
    [NSDictionary safeSetObjectInDictionary:json object:locatorUrlString withKey:@"locatorUrl"];
    
    return json;
}

#pragma mark -
#pragma mark NSCopying
- (id)copyWithZone:(NSZone *)zone
{
    AGSPoint *ptCopy = (AGSPoint *)[self.geometry copy];
    Location *copyLocation = [[Location alloc] initWithPoint:ptCopy
                                                       aName:self.name 
                                                      anIcon:self.defaultIcon 
                                                   locatorURL:self.locatorUrl];
    
    copyLocation.locationType = _locationType;
    copyLocation.addressCandidate = self.addressCandidate;
    return copyLocation;
}


@end
