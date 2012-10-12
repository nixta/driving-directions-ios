/*
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

#import "Search.h"
#import "NSDictionary+Additions.h"

@implementation Search

-(id)initWithName:(NSString *)name
{
    self = [super init];
    if(self)
    {
        self.name = name;
        self.icon = [UIImage imageNamed:@"MagnifyingGlass.png"];
    }
    
    return self;
}

- (id)init
{
    return [self initWithName:NSLocalizedString(@"Search", nil)];
}


#pragma mark -
#pragma mark - AGSCoding

- (id)initWithJSON:(NSDictionary *)json
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
    self.name = [AGSJSONUtility getStringFromDictionary:json withKey:@"name"];
    
    NSString *base64IconString = [NSDictionary safeGetObjectFromDictionary:json withKey:@"icon"];
    if (base64IconString) {
        NSData *iconData = [AGSBase64 decode:base64IconString];
        self.icon = [UIImage imageWithData:iconData];
    }
}

- (NSDictionary *)encodeToJSON
{
    NSMutableDictionary *json = [NSMutableDictionary dictionaryWithCapacity:3];
    
    [NSDictionary safeSetObjectInDictionary:json object:self.name withKey:@"name"];
    
    NSData *iconData = UIImagePNGRepresentation(self.icon);
    NSString *base64Icon = [AGSBase64 encode:iconData];
    [NSDictionary safeSetObjectInDictionary:json object:base64Icon withKey:@"icon"];
    
    return json;
}

@end
