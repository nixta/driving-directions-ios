/*
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */
#import "LocationBookmark.h"
#import "location.h"

@implementation LocationBookmark

@synthesize envelope = _envelope;



-(id)initWithLocation:(Location *)location extent:(AGSEnvelope *)extent
{
    
    AGSPoint *newLoc = (AGSPoint *)[location.geometry mutableCopy];
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
    
    self.envelope = [[AGSEnvelope alloc] initWithJSON:[json objectForKey:@"envelope"]];
    
    //Added because encoding/decoding image was making image larger
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
