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

@property (nonatomic, strong) NSString *geometryServiceUrl;
@property (nonatomic, strong) NSString *geocodeServiceUrl;
@property (nonatomic, strong) NSString *locatorServiceUrl;
@property (nonatomic, strong) NSString *worldLocatorServiceUrl;
@property (nonatomic, strong) NSString *esriGlobalAccount;
@property (nonatomic, strong) NSString *arcgisRegistrationUrl;
@property (nonatomic, strong) NSString *ecasRegistrationUrl;
@property (nonatomic, strong) NSString *sharing;
@property (nonatomic, strong) NSString *legend;
@property (nonatomic, strong) NSString *bingMapsKey;
@property (nonatomic, strong) NSString *basemapsGroupQueries;
@property (nonatomic, strong) NSString *featuredMapsGroupQueries;
@property (nonatomic, assign) NSInteger tokenExpiration;
@property (nonatomic, assign) BOOL      showSocialMediaLinks;
@property (nonatomic, assign) BOOL      enableBitly;
@property (nonatomic, strong) NSString *bitlyLogin;
@property (nonatomic, strong) NSString *bitlyKey;
@property (nonatomic, strong) NSString *portalName;
@property (nonatomic, strong) NSString *defaultMap;
@property (nonatomic, strong) AGSEnvelope *defaultMapExtent;

+(ArcGISMobileConfig *)defaultConfig;

@end
