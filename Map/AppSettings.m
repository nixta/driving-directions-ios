//
//  AppSettings.m
//  Map
//
//  Created by Scott Sirowy on 9/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

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
