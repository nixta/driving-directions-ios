//
//  LocationBookmark.m
//  Map
//
//  Created by Scott Sirowy on 9/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LocationBookmark.h"
#import "location.h"

@implementation LocationBookmark

@synthesize envelope = _envelope;

-(void)dealloc
{
    self.envelope = nil;
    [super dealloc];
}


-(id)initWithLocation:(Location *)location extent:(AGSEnvelope *)extent
{
    
    AGSPoint *newLoc = (AGSPoint *)[[location.geometry mutableCopy] autorelease];
    self = [super initWithPoint:newLoc
                          aName:location.name 
                         anIcon:location.icon   
                     locatorURL:location.locatorUrl];
    
    if(self)
    {
        self.envelope = extent;
    }
    
    return self;
}

#pragma mark -
#pragma mark AGSCoding
- (void)decodeWithJSON:(NSDictionary *)json
{
    [super decodeWithJSON:json];
    
    self.envelope = [[[AGSEnvelope alloc] initWithJSON:[json objectForKey:@"envelope"]] autorelease];
    
#warning Added because encoding/decoding image was making image larger
    self.icon = [UIImage imageNamed:@"BookmarkPin.png"];
}

- (NSDictionary *)encodeToJSON
{
    NSMutableDictionary *json = (NSMutableDictionary *)[super encodeToJSON];
    
    [json setObject:[self.envelope encodeToJSON] forKey:@"envelope"];
    
    return json;
}

-(id)initWithJSON:(NSDictionary *)json
{
    self = [self init];
    if(self)
    {
        [self decodeWithJSON:json];
    }
    
    return self;
}

@end
