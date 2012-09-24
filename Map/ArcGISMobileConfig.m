//
//  ArcGISMobileConfig.m
//  ArcGISMobile
//
//  Created by Mark Dostal on 4/26/11.
//  Copyright 2011 ESRI. All rights reserved.
//

#import "ArcGISMobileConfig.h"
#import "NSDictionary+Additions.h"

@implementation ArcGISMobileConfig

@synthesize geometryServiceUrl = _geometryServiceUrl;
@synthesize geocodeServiceUrl = _geocodeServiceUrl;
@synthesize locatorServiceUrl = _locatorServiceUrl;
@synthesize worldLocatorServiceUrl = _worldLocatorServiceUrl;
@synthesize esriGlobalAccount = _esriGlobalAccount;
@synthesize arcgisRegistrationUrl = _arcgisRegistrationUrl;
@synthesize ecasRegistrationUrl = _ecasRegistrationUrl;

@synthesize sharing = _sharing;
@synthesize legend = _legend;
@synthesize bingMapsKey = _bingMapsKey;
@synthesize basemapsGroupQueries = _basemapsGroupQueries;
@synthesize featuredMapsGroupQueries = _featuredMapsGroupQueries;
@synthesize tokenExpiration = _tokenExpiration;
@synthesize showSocialMediaLinks = _showSocialMediaLinks;
@synthesize enableBitly = _enableBitly;
@synthesize bitlyLogin = _bitlyLogin;
@synthesize bitlyKey = _bitlyKey;
@synthesize portalName = _portalName;
@synthesize defaultMap = _defaultMap;
@synthesize defaultMapExtent = _defaultMapExtent;

-(id)init{
	if (self = [super init]){
        //
        // set default values
        // We're doing this here so that all configs will have
        // default values and so that the 'decodeWithJSON' method
        // does not have to worry about defaults for items not
        // in the json dictionary
        //
        
        //Original values...
        self.geocodeServiceUrl = @"http://tasks.arcgisonline.com/ArcGIS/rest/services/Locators/TA_Streets_US/GeocodeServer";
        self.geometryServiceUrl = @"http://tasks.arcgisonline.com/ArcGIS/rest/services/Geometry/GeometryServer";
        self.locatorServiceUrl = @"http://tasks.arcgis.com/ArcGIS/rest/services/WorldLocator/geocodeserver";
        self.worldLocatorServiceUrl = @"http://tasks.arcgis.com/ArcGIS/rest/services/WorldLocator/LocationServer";
        self.esriGlobalAccount = @"https://webaccounts.esri.com/cas/index.cfm?fuseaction=Registration.ShowForm&ReturnURL=https%3A%2F%2Fwww.arcgis.com%2Fhome%2Fsignup.html&FailURL=http%3A%2F%2Fwww.arcgis.com&appId=RC10SB959G";
        self.arcgisRegistrationUrl = @"https://www.arcgis.com/sharing/community/signup";
        
        //v2.0 values (for original ArcGIS Portal implementation)
        self.sharing = @"http://www.arcgis.com/sharing";
        self.legend = @"http://www.arcgis.com/sharing/tools/legend";
        self.bingMapsKey = @"ApW8SZU7fZGUZ9eoEfyp6nJZdrcVM7s2TMWqtDx7PWEh74OZBN1lHVaAiZf-fUwZ";
        self.basemapsGroupQueries = @"title:\"ArcGIS Online Basemaps\" AND owner:esri";
        self.featuredMapsGroupQueries = @"\"ESRI Featured Content\" AND owner:esri";
        self.tokenExpiration = 525600;
        self.showSocialMediaLinks = YES;
        self.enableBitly = YES;
        self.bitlyLogin = @"arcgis";
        self.bitlyKey = @"R_b8a169f3a8b978b9697f64613bf1db6d";
        self.portalName = @"";
        self.defaultMap = @"{\"operationalLayers\":[],\"baseMap\":{\"baseMapLayers\":[{\"id\":\"defaultBasemap\",\"opacity\":1,\"visibility\":true,\"url\":\"http://services.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer\"}],\"title\":\"Topographic\"},\"version\":\"1.2\"}";
        self.defaultMapExtent = [[AGSEnvelope alloc]initWithXmin:-135.7032 ymin:-3.4998 xmax:-56.1622 ymax:64.592 spatialReference:[AGSSpatialReference spatialReferenceWithWKID:4326 WKT:nil]];
        self.ecasRegistrationUrl = @"https://ecasapi.esri.com/1.0/accounts";
	}

	return self;
}

//helper class method
+(ArcGISMobileConfig *)defaultConfig {
    ArcGISMobileConfig *config = [[ArcGISMobileConfig alloc] init];
    
    return config;
}

#pragma mark -
#pragma mark AGSCoding

- (void)decodeWithJSON:(NSDictionary *)json {
    
	//
	// sample response
	/* // sample response:
	 {
     "uris":{
     "geometryService":"http://sampleserver3.arcgisonline.com/ArcGIS/rest/services/Geometry/GeometryServer"
     "geocodeService":"http://sampleserver1.arcgisonline.com/ArcGIS/rest/services/Locators/ESRI_Geocode_USA/GeocodeServer"
     "esriGlobalAccount":"https://webaccounts.esri.com/cas/index.cfm?fuseaction=Registration.ShowForm&ReturnURL=https%3A%2F%2Fwww.arcgis.com%2Fhome%2Fsignup.html&FailURL=http%3A%2F%2Fwww.arcgis.com&appId=RC10SB959G"
     "arcgisRegistration":"https://www.arcgis.com/sharing/community/signup"
     "ecasRegistration":"http://webaccounts.esri.com/mobile/iphone/index.cfm"
     }
	 }
	 */
    
    NSDictionary *properties = [json valueForKey:@"uris"];
	
	// pull out geometryService url
	NSString *tmp = [AGSJSONUtility getStringFromDictionary:properties withKey:@"geometryService"];
	if (tmp != nil){
		self.geometryServiceUrl = tmp;
	}
	
	// pull out geocodeService url
	tmp = [AGSJSONUtility getStringFromDictionary:properties withKey:@"geocodeService"];
	if (tmp != nil){
		self.geocodeServiceUrl = tmp;
	}
	
	// pull out locatorService url
	tmp = [AGSJSONUtility getStringFromDictionary:properties withKey:@"locatorService"];
	if (tmp != nil){
		self.locatorServiceUrl = tmp;
	}
	
	// pull out locator service url - this is the version 2.01 (and future) service
    //this is initially the new locator/new API service used for findPlace
    //and eventually (post v2.01) findAddressCandidate
	tmp = [AGSJSONUtility getStringFromDictionary:properties withKey:@"worldLocatorService"];
	if (tmp != nil){
		self.worldLocatorServiceUrl = tmp;
	}
	
	// pull out esriGlobalAccount url
	tmp = [AGSJSONUtility getStringFromDictionary:properties withKey:@"esriGlobalAccount"];
	if (tmp != nil){
		self.esriGlobalAccount = tmp;
	}
	
	// pull out arcgisRegistration url
	tmp = [AGSJSONUtility getStringFromDictionary:properties withKey:@"arcgisRegistration"];
	if (tmp != nil){
		self.arcgisRegistrationUrl = tmp;
	}
	
	// ecasRegistration
	tmp = [AGSJSONUtility getStringFromDictionary:properties withKey:@"ecasRegistration"];
	if (tmp != nil){
		self.ecasRegistrationUrl = tmp;
	}
    
	// sharing
	tmp = [AGSJSONUtility getStringFromDictionary:properties withKey:@"sharing"];
	if (tmp != nil){
		self.sharing = tmp;
	}
	
	// legend
	tmp = [AGSJSONUtility getStringFromDictionary:properties withKey:@"legend"];
	if (tmp != nil){
		self.legend = tmp;
	}
	
	// bingMapsKey
	tmp = [AGSJSONUtility getStringFromDictionary:properties withKey:@"bingMapsKey"];
	if (tmp != nil){
		self.bingMapsKey = tmp;
	}
	
	// basemapsGroupQueries
	tmp = [AGSJSONUtility getStringFromDictionary:properties withKey:@"basemapsGroupQueries"];
	if (tmp != nil){
		self.basemapsGroupQueries = tmp;
	}
	
	// featuredMapsGroupQueries
	tmp = [AGSJSONUtility getStringFromDictionary:properties withKey:@"featuredMapsGroupQueries"];
	if (tmp != nil){
		self.featuredMapsGroupQueries = tmp;
	}
	
	// tokenExpiration
	NSNumber *tokenExpiration = [properties valueForKey:@"tokenExpiration"];
	if (tokenExpiration != nil){
		self.tokenExpiration = [tokenExpiration unsignedIntValue];
	}
	
	// showSocialMediaLinks
	NSNumber *showSocialMediaLinks = [properties valueForKey:@"showSocialMediaLinks"];
	if (showSocialMediaLinks != nil){
		self.showSocialMediaLinks = [showSocialMediaLinks boolValue];
	}
	
	// enableBitly
	NSNumber *enableBitly = [properties valueForKey:@"enableBitly"];
	if (tmp != nil){
		self.enableBitly = [enableBitly boolValue];
	}
	
	// bitlyLogin
	tmp = [AGSJSONUtility getStringFromDictionary:properties withKey:@"bitlyLogin"];
	if (tmp != nil){
		self.bitlyLogin = tmp;
	}
	
	// bitlyKey
	tmp = [AGSJSONUtility getStringFromDictionary:properties withKey:@"bitlyKey"];
	if (tmp != nil){
		self.bitlyKey = tmp;
	}
	
	// bitlyKey
	tmp = [AGSJSONUtility getStringFromDictionary:properties withKey:@"portalName"];
	if (tmp != nil){
		self.portalName = tmp;
	}
	
	// default map id
	tmp = [AGSJSONUtility getStringFromDictionary:properties withKey:@"defaultMap"];
	if (tmp != nil){
		self.defaultMap = tmp;
	}
    
    tmp = [NSDictionary safeGetObjectFromDictionary:properties withKey:@"defaultMapExtent"];
	if (tmp != nil){
        self.defaultMapExtent = [[AGSEnvelope alloc] initWithJSON:[tmp AGSJSONValue]];
    }
}

- (id)initWithJSON:(NSDictionary *)json {
    //in order to make sure we're fully initialized,
    //call [self init] instead of [super init].
    //[self init will call [super init]
    if (self = [self init]) {
        [self decodeWithJSON:json];
    }
    return self;
}

- (NSDictionary *)encodeToJSON;
{
	NSMutableDictionary *json = [NSMutableDictionary dictionaryWithCapacity:3];

    NSDictionary *configDict = [NSDictionary dictionaryWithObjectsAndKeys:self.geometryServiceUrl, @"geometryService",
                                self.geocodeServiceUrl, @"geocodeService",
                                self.locatorServiceUrl, @"locatorService",
                                self.worldLocatorServiceUrl, @"worldLocatorService",
                                self.esriGlobalAccount, @"esriGlobalAccount",
                                self.arcgisRegistrationUrl, @"arcgisRegistration",
                                self.ecasRegistrationUrl, @"ecasRegistration",
                                self.sharing, @"sharing",
                                self.legend, @"legend",
                                self.bingMapsKey, @"bingMapsKey",
                                self.basemapsGroupQueries, @"basemapsGroupQueries",
                                self.featuredMapsGroupQueries, @"featuredMapsGroupQueries",
                                [NSNumber numberWithUnsignedInt:self.tokenExpiration], @"tokenExpiration",
                                [NSNumber numberWithBool:self.showSocialMediaLinks], @"showSocialMediaLinks",
                                [NSNumber numberWithBool:self.enableBitly], @"enableBitly",
                                self.bitlyLogin, @"bitlyLogin",
                                self.bitlyKey, @"bitlyKey",
                                self.portalName, @"portalName",
                                self.defaultMap, @"defaultMap",
                                nil];
    
    if (self.defaultMapExtent != nil)
    {
        NSDictionary *extentJSON = [self.defaultMapExtent encodeToJSON];
        [configDict setValue:[extentJSON AGSJSONRepresentation] forKey:@"defaultMapExtent"];
    }
    
    [json setObject:configDict forKey:@"uris"];
    
	return json;
}

#pragma mark -
#pragma mark Memory Management

@end
