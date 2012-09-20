//
//  ArcGISMobileConfig.h
//  ArcGISMobile
//
//  Created by Mark Dostal on 4/26/11.
//  Copyright 2011 ESRI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ArcGIS+App.h"


@interface ArcGISMobileConfig : NSObject <AGSCoding> {
	NSString *_geometryServiceUrl;
	NSString *_geocodeServiceUrl;
	NSString *_locatorServiceUrl;
	NSString *_worldLocatorServiceUrl;
	NSString *_esriGlobalAccount;
	NSString *_arcgisRegistrationUrl;
    NSString *_ecasRegistrationUrl;
    NSString *_sharing;
    NSString *_legend;
    NSString *_bingMapsKey;
    NSString *_basemapsGroupQueries;
    NSString *_featuredMapsGroupQueries;
    NSInteger _tokenExpiration;
    BOOL      _showSocialMediaLinks;
    BOOL      _enableBitly;
    NSString *_bitlyLogin;
    NSString *_bitlyKey;
    NSString *_portalName;
    NSString *_defaultMap;
    AGSEnvelope *_defaultMapExtent;
}

@property (nonatomic, retain) NSString *geometryServiceUrl;
@property (nonatomic, retain) NSString *geocodeServiceUrl;
@property (nonatomic, retain) NSString *locatorServiceUrl;
@property (nonatomic, retain) NSString *worldLocatorServiceUrl;
@property (nonatomic, retain) NSString *esriGlobalAccount;
@property (nonatomic, retain) NSString *arcgisRegistrationUrl;
@property (nonatomic, retain) NSString *ecasRegistrationUrl;
@property (nonatomic, retain) NSString *sharing;
@property (nonatomic, retain) NSString *legend;
@property (nonatomic, retain) NSString *bingMapsKey;
@property (nonatomic, retain) NSString *basemapsGroupQueries;
@property (nonatomic, retain) NSString *featuredMapsGroupQueries;
@property (nonatomic, assign) NSInteger tokenExpiration;
@property (nonatomic, assign) BOOL      showSocialMediaLinks;
@property (nonatomic, assign) BOOL      enableBitly;
@property (nonatomic, retain) NSString *bitlyLogin;
@property (nonatomic, retain) NSString *bitlyKey;
@property (nonatomic, retain) NSString *portalName;
@property (nonatomic, retain) NSString *defaultMap;
@property (nonatomic, retain) AGSEnvelope *defaultMapExtent;

+(ArcGISMobileConfig *)defaultConfig;

@end
