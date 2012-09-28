//
//  Organization.m
//  Map
//
//  Created by Scott Sirowy on 9/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

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

-(NSURL *)routeUrl
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

//San Fran Map
#define kSanFranMap @"71cd43367e7a4ec8aebca536cf5b92fd"

#pragma mark -
#pragma mark San Francisco Organization
@implementation SanFranciscoOrganization

-(void)retrieveOrganizationWebmap
{
    if(_webmap == nil)
    {
        AGSCredential *credential = [[AGSCredential alloc] initWithUser:@"mobile_org" password:@"dev.team"];
        credential.authType = AGSAuthenticationTypeToken;
        //credential.tokenUrl = [NSURL URLWithString:@"https://www.arcgis.com/sharing/generateToken"];
        
        self.webmap = [AGSWebMap webMapWithItemId:kSanFranMap credential:credential];
        self.webmap.delegate = self;
    }
    else if(self.webmapLoaded)
    {
        [self finalizeWebMapDownloadWithSuccess:YES];
    }
}

-(NSURL *)routeUrl
{    
    //San Francisco Route Service
    return [NSURL URLWithString:@"http://mobilesampleserver.arcgisonline.com/ArcGIS/rest/services/TestData/SanFrancisco/NAServer/Route"];
    
    //10.1 San Francisco Route Service
    //return @"http://ec2-67-202-61-94.compute-1.amazonaws.com:6080/arcgis/rest/services/SanFranciscoNetwork/NAServer/Route";
}

@end


//Parolee Map
#define kParoleeMap @"e85a3564d97b4ea1bbd8bd463a453a13"

#pragma mark -
#pragma mark Police Organization
@implementation PoliceOrganization

-(void)retrieveOrganizationWebmap
{
    if(_webmap == nil)
    {
        AGSCredential *credential = [[AGSCredential alloc] initWithUser:@"mobile_org" password:@"dev.team"];
        credential.authType = AGSAuthenticationTypeToken;
        //credential.tokenUrl = [NSURL URLWithString:@"https://www.arcgis.com/sharing/generateToken"];
        
        self.webmap = [AGSWebMap webMapWithItemId:kParoleeMap credential:credential];
        self.webmap.delegate = self;
    }
    else if(self.webmapLoaded)
    {
        [self finalizeWebMapDownloadWithSuccess:YES];
    }
}

@end


#define kATTMap @"fd36463521224cd8a0e84000b813c3eb"

#pragma mark -
#pragma mark ATT Organization
@implementation ATTOrganization

-(void)retrieveOrganizationWebmap
{
    if(_webmap == nil)
    {
        AGSCredential *credential = [[AGSCredential alloc] initWithUser:@"mobileios" password:@"bazinga"];
        credential.authType = AGSAuthenticationTypeToken;
        //credential.tokenUrl = [NSURL URLWithString:@"https://www.arcgis.com/sharing/generateToken"];
        
        self.webmap = [AGSWebMap webMapWithItemId:kATTMap credential:credential];
        self.webmap.delegate = self;
    }
    else if(self.webmapLoaded)
    {
        [self finalizeWebMapDownloadWithSuccess:YES];
    }
}

@end
 

#define kTeapotMap @"71add2d505954e5e90dad5d9b52c4c18"

#pragma mark -
#pragma mark Teapot Organization
@implementation TeapotOrganization

-(void)retrieveOrganizationWebmap
{
    if(_webmap == nil)
    {
        AGSCredential *credential = [[AGSCredential alloc] initWithUser:@"mobileios" password:@"bazinga"];
        credential.authType = AGSAuthenticationTypeToken;
        //credential.tokenUrl = [NSURL URLWithString:@"https://www.arcgis.com/sharing/generateToken"];
        
        self.webmap = [AGSWebMap webMapWithItemId:kTeapotMap credential:credential];
        self.webmap.delegate = self;
    }
    else if(self.webmapLoaded)
    {
        [self finalizeWebMapDownloadWithSuccess:YES];
    }
}

-(NSURL *)routeUrl
{    
    return [NSURL URLWithString:@"http://mobilesampleserver.arcgisonline.com/ArcGIS/rest/services/DemoData/TP_Routing2/NAServer/Route"];
}

//overloaded...
-(AGSEnvelope *)defaultEnvelope
{
    AGSEnvelope *teapotDomeEnv = [AGSEnvelope envelopeWithXmin:-11823166.083019 
                                                          ymin:5355300.183105
                                                          xmax:-11821778.028526 
                                                          ymax:5357295.511437 
                                              spatialReference:[AGSSpatialReference webMercatorSpatialReference]];
    
    return teapotDomeEnv;
}

@end
