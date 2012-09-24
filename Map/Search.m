//
//  Search.m
//  Map
//
//  Created by Scott Sirowy on 9/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Search.h"
#import "NSDictionary+Additions.h"

@implementation Search

@synthesize name = _name;
@synthesize icon = _icon;


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
