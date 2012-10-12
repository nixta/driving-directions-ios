/*
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

#import "AppSettings.h"
#import "ArcGISOnlineConnection.h"
#import "NSDictionary+Additions.h"

@implementation AppSettings

@synthesize arcGISOnlineConnection = _arcGISOnlineConnection;

#pragma mark -
#pragma mark Lifetime
- (id)init
{
    self = [super init];
    if (self) {
        self.arcGISOnlineConnection = [[ArcGISOnlineConnection alloc] init];
    }
    
    return self;
}



#pragma mark -
#pragma mark AGSCoding

- (void)decodeWithJSON:(NSDictionary *)json 
{
	self.arcGISOnlineConnection = [[ArcGISOnlineConnection alloc]initWithJSON:[json objectForKey:@"arcgisOnlineConnection"]];
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
	
    [json setObject:[self.arcGISOnlineConnection encodeToJSON] forKey:@"arcgisOnlineConnection"];
	    
	return json;
}





@end
