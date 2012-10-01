//
//  Organization.m
//  Map
//
//  Created by Scott Sirowy on 9/9/11.
/*
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

#import "Organization.h"
#import <ArcGIS/ArcGIS.h>
#import "ArcGISAppDelegate.h"
#import "ArcGISMobileConfig.h"
#import "ArcGISOnlineConnection.h"



//#define kDefaultWebMapId @"15d033f017454856a0fb65f56b9c5a15"
#define kDefaultWebMapId @"5b84b12a666c477db2842bb5800d87c7"


@interface Organization () 

-(void)finalizeWebMapDownloadWithSuccess:(BOOL)success;

@property (nonatomic, strong) AGSJSONRequestOperation *orgOperation;

@end

@implementation Organization

@synthesize webmap = _webmap;
@synthesize webmapLoaded = _webmapLoaded;
@synthesize icon = _icon;
@synthesize defaultEnvelope = _defaultEnvelope;

@synthesize name = _name;
@synthesize basemapGalleryGroupQuery = _basemapGalleryGroupQuery;
@synthesize portalName = _portalName;
@synthesize locatorUrlString = _locatorUrlString;

@synthesize delegate = _delegate;

@synthesize orgOperation = _orgOperation;


- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void)retrieveOrganizationWebmap
{
    if(_webmap == nil)
    {
        // public webmap
        self.webmap = [AGSWebMap webMapWithItemId:kDefaultWebMapId credential:nil];
        self.webmap.delegate = self;
    }
    else if(self.webmapLoaded)
    {
        [self finalizeWebMapDownloadWithSuccess:YES];
    }
}

-(void)finalizeWebMapDownloadWithSuccess:(BOOL)success
{
    _webmapLoaded = success;
    
    if (success) {
        if([self.delegate respondsToSelector:@selector(organization:didDownloadWebmap:)])
        {
            [self.delegate organization:self didDownloadWebmap:self.webmap];
        }
    }
    else
    {
        if([self.delegate respondsToSelector:@selector(organizationDidFailToDownloadWebmap:)])
        {
            [self.delegate organizationDidFailToDownloadWebmap:self];
        }
    }
}

-(NSURL *)routeUrlbase
{    
    //US Route Server
    // looking for the world routing service
    return [NSURL URLWithString:@"http://tasks.arcgisonline.com/ArcGIS/rest/services/NetworkAnalysis/ESRI_Route_NA/NAServer/Route"];
}


//defaults to returning the Redlands envelope, in Web Mercator...  Really only for testing purposes
-(AGSEnvelope *)defaultEnvelope
{
    AGSEnvelope *redlandsEnv = [AGSEnvelope envelopeWithXmin:-13056134.334280 
                                                        ymin:4020198.085079 
                                                        xmax:-13033785.293456 
                                                        ymax:4052324.831262 
                                            spatialReference:[AGSSpatialReference webMercatorSpatialReference]];
    
    return redlandsEnv;
}


#pragma -
#pragma AGSWebMapDelegate

- (void)webMapDidLoad:(AGSWebMap *)webMap
{
    [self finalizeWebMapDownloadWithSuccess:YES];
}

- (void)webMap:(AGSWebMap *)webMap didFailToLoadWithError:(NSError *)error
{
     NSLog(@"Error: %@", [error localizedDescription]);
     [self finalizeWebMapDownloadWithSuccess:NO];
}


#pragma mark -
#pragma mark AGSCoding

-(id)initWithJSON:(NSDictionary *)json
{
    //in order to make sure we're fully initialized,
    //call [self init] instead of [super init].
    //[self init will call [super init]
    if (self = [self init]) {
        [self decodeWithJSON:json];
    }
    return self;
}

- (void)decodeWithJSON:(NSDictionary *)json
{
    self.basemapGalleryGroupQuery = [AGSJSONUtility getStringFromDictionary:json withKey:@"basemapGalleryGroupQuery"];
    self.name = [AGSJSONUtility getStringFromDictionary:json withKey:@"name"];
    self.portalName = [AGSJSONUtility getStringFromDictionary:json withKey:@"portalName"];
}

- (NSDictionary *)encodeToJSON
{
    NSLog(@"Encoding Org JSON");
    return nil;
}

@end


