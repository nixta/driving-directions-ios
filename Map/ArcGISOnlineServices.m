/*
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

#import "ArcGISOnlineServices.h"
#import "ArcGISOnlineConnection.h"
#import "NSDictionary+Additions.h"

#pragma mark -
#pragma mark TokenResponse

@implementation TokenResponse

- (void)decodeWithJSON:(NSDictionary *)json {
	self.token = [AGSJSONUtility getStringFromDictionary:json withKey:@"token"];
    self.expires = [[json valueForKey:@"expires"]intValue];
}


- (id)initWithJSON:(NSDictionary *)json {
    if (self = [super init]) {
        [self decodeWithJSON:json];
    }
    return self;
}

- (NSDictionary *)encodeToJSON;
{
	NSMutableDictionary *json = [NSMutableDictionary dictionaryWithCapacity:2];
	
	[NSDictionary safeSetObjectInDictionary:json object:self.token withKey:@"token"];
	[json setValue:[NSNumber numberWithInt:self.expires] forKey:@"expires"];
    return json;
}


@end

#pragma mark -
#pragma mark User

@implementation User


- (void)decodeWithJSON:(NSDictionary *)json {
	self.userName = [AGSJSONUtility getStringFromDictionary:json withKey:@"username"];
	self.fullName = [AGSJSONUtility getStringFromDictionary:json withKey:@"fullName"];
	self.description = [AGSJSONUtility getStringFromDictionary:json withKey:@"description"];
	self.email = [AGSJSONUtility getStringFromDictionary:json withKey:@"email"];
	self.organization = [AGSJSONUtility getStringFromDictionary:json withKey:@"organization"];
	self.defaultGroupId = [AGSJSONUtility getStringFromDictionary:json withKey:@"defaultGroupId"];
    self.groups = [AGSJSONUtility decodeFromDictionary:json withKey:@"groups" fromClass:[Group class]];
}


- (id)initWithJSON:(NSDictionary *)json {
    if (self = [super init]) {
        [self decodeWithJSON:json];
    }
    return self;
}

- (NSDictionary *)encodeToJSON;
{
	NSMutableDictionary *json = [NSMutableDictionary dictionaryWithCapacity:7];
	
	[NSDictionary safeSetObjectInDictionary:json object:self.userName withKey:@"username"];
	[NSDictionary safeSetObjectInDictionary:json object:self.fullName withKey:@"fullName"];
	[NSDictionary safeSetObjectInDictionary:json object:self.description withKey:@"description"];
	[NSDictionary safeSetObjectInDictionary:json object:self.email withKey:@"email"];
	[NSDictionary safeSetObjectInDictionary:json object:self.organization withKey:@"organization"];
	[NSDictionary safeSetObjectInDictionary:json object:self.defaultGroupId withKey:@"defaultGroupId"];
    [AGSJSONUtility encodeToDictionary:json withKey:@"groups" AGSCodingArray:self.groups];
    return json;
}


@end

#pragma mark -
#pragma mark Member

@implementation Member

- (void)decodeWithJSON:(NSDictionary *)json {
	self.userName = [AGSJSONUtility getStringFromDictionary:json withKey:@"username"];
	self.memberType = [AGSJSONUtility getStringFromDictionary:json withKey:@"memberType"];
}


- (id)initWithJSON:(NSDictionary *)json {
    if (self = [super init]) {
        [self decodeWithJSON:json];
    }
    return self;
}

- (NSDictionary *)encodeToJSON;
{
	NSMutableDictionary *json = [NSMutableDictionary dictionaryWithCapacity:2];
	
	[NSDictionary safeSetObjectInDictionary:json object:self.userName withKey:@"username"];
	[NSDictionary safeSetObjectInDictionary:json object:self.memberType withKey:@"memberType"];
    return json;
}


@end

#pragma mark -
#pragma mark Group

@implementation Group


- (void)decodeWithJSON:(NSDictionary *)json {
	self.groupId = [AGSJSONUtility getStringFromDictionary:json withKey:@"id"];
	self.title = [AGSJSONUtility getStringFromDictionary:json withKey:@"title"];
	self.description = [AGSJSONUtility getStringFromDictionary:json withKey:@"description"];
	self.snippet = [AGSJSONUtility getStringFromDictionary:json withKey:@"snippet"];
	self.phone = [AGSJSONUtility getStringFromDictionary:json withKey:@"phone"];
	self.thumbnail = [AGSJSONUtility getStringFromDictionary:json withKey:@"thumbnail"];
	self.owner = [AGSJSONUtility getStringFromDictionary:json withKey:@"owner"];
    
    NSDecimalNumber *_decimal = [NSDecimalNumber decimalNumberWithDecimal:[[json valueForKey:@"created"] decimalValue]];
    self.created = [_decimal doubleValue];
    
    self.isPublic = [[json valueForKey:@"isPublic"] boolValue];
    self.isInvitationOnly = [[json valueForKey:@"isInvitationOnly"] boolValue];
    self.isOrganization = [[json valueForKey:@"isOrganization"] boolValue];
	self.featuredItemsId = [AGSJSONUtility getStringFromDictionary:json withKey:@"featuredItemsId"];
    
    self.tags = [json valueForKey:@"tags"];

    //this is incorrect.  usermembership is a different structure.
    //we're currently not using it...
    //self.members = [JSONUtility decodeFromDictionary:json withKey:@"userMembership" fromClass:[Member class]];
}


- (id)initWithJSON:(NSDictionary *)json {
    if (self = [super init]) {
        [self decodeWithJSON:json];
    }
    return self;
}

- (NSDictionary *)encodeToJSON;
{
	NSMutableDictionary *json = [NSMutableDictionary dictionaryWithCapacity:8];
	
	[NSDictionary safeSetObjectInDictionary:json object:self.groupId withKey:@"id"];
	[NSDictionary safeSetObjectInDictionary:json object:self.title withKey:@"title"];
	[NSDictionary safeSetObjectInDictionary:json object:self.description withKey:@"description"];
	[NSDictionary safeSetObjectInDictionary:json object:self.snippet withKey:@"snippet"];
	[NSDictionary safeSetObjectInDictionary:json object:self.phone withKey:@"phone"];
	[NSDictionary safeSetObjectInDictionary:json object:self.thumbnail withKey:@"thumbnail"];
	[NSDictionary safeSetObjectInDictionary:json object:self.owner withKey:@"owner"];
	[json setValue:[NSNumber numberWithDouble:self.created] forKey:@"created"];
	[json setValue:[NSNumber numberWithBool:self.isPublic] forKey:@"isPublic"];
	[json setValue:[NSNumber numberWithBool:self.isOrganization] forKey:@"isOrganization"];
	[json setValue:[NSNumber numberWithBool:self.isInvitationOnly] forKey:@"isInvitationOnly"];
	[NSDictionary safeSetObjectInDictionary:json object:self.featuredItemsId withKey:@"featuredItemsId"];
    
    if (self.tags != nil)
        [json setObject:self.tags forKey:@"tags"];

    //see above (decodeWithJSON)
    //[JSONUtility encodeToDictionary:json withKey:@"userMembership" AGSCodingArray:self.members];
    return json;
}

-(NSString *)groupThumbnailURLString
{
    return [NSString stringWithFormat:@"community/groups/%@/info/%@",
                 self.groupId,
                 self.thumbnail];
}


@end

#pragma mark -
#pragma mark SearchResults

@implementation SearchResults

- (void)decodeWithJSON:(NSDictionary *)json {
}


- (id)initWithJSON:(NSDictionary *)json {
    if (self = [super init]) {
        [self decodeWithJSON:json];
    }
    return self;
}

- (NSDictionary *)encodeToJSON;
{
	NSMutableDictionary *json = [NSMutableDictionary dictionaryWithCapacity:2];
	
    return json;
}


@end

#pragma mark -
#pragma mark SearchResponse

@implementation SearchResponse

- (void)decodeWithJSON:(NSDictionary *)json {
	self.total = [[json valueForKey:@"total"]intValue];
    self.start = [[json valueForKey:@"start"]intValue];
    self.num = [[json valueForKey:@"num"]intValue];
    self.nextStart = [[json valueForKey:@"nextStart"]intValue];
    
    //for now, the search results will have to be decoded separatelty.  This
    //is because the format of the results could be either maps or groups
    //and I'm not sure if it's possible to decode both...
    //self.results = [JSONUtility decodeFromDictionary:json withKey:@"results" fromClass:[SearchResults class]];
}


- (id)initWithJSON:(NSDictionary *)json {
    if (self = [super init]) {
        [self decodeWithJSON:json];
    }
    return self;
}

- (NSDictionary *)encodeToJSON;
{
	NSMutableDictionary *json = [NSMutableDictionary dictionaryWithCapacity:5];
	
	[json setValue:[NSNumber numberWithInt:self.total] forKey:@"total"];
    [json setValue:[NSNumber numberWithInt:self.start] forKey:@"start"];
    [json setValue:[NSNumber numberWithInt:self.num] forKey:@"num"];
    [json setValue:[NSNumber numberWithInt:self.nextStart] forKey:@"nextStart"];
    //[JSONUtility encodeToDictionary:json withKey:@"results" AGSCodingArray:self.results];
    return json;
}


@end


#pragma mark -
#pragma mark ContentFolder

@implementation ContentFolder


- (void)decodeWithJSON:(NSDictionary *)json {
	self.folderId = [AGSJSONUtility getStringFromDictionary:json withKey:@"id"];
	self.title = [AGSJSONUtility getStringFromDictionary:json withKey:@"title"];
	self.userName = [AGSJSONUtility getStringFromDictionary:json withKey:@"username"];
    
    NSDecimalNumber *_decimal = [NSDecimalNumber decimalNumberWithDecimal:[[json valueForKey:@"created"] decimalValue]];
    self.created = [_decimal doubleValue];
}

- (id)initWithJSON:(NSDictionary *)json {
    if (self = [super init]) {
        [self decodeWithJSON:json];
    }
    return self;
}

- (NSDictionary *)encodeToJSON;
{
	NSMutableDictionary *json = [NSMutableDictionary dictionaryWithCapacity:8];
	
	[NSDictionary safeSetObjectInDictionary:json object:self.folderId withKey:@"id"];
	[NSDictionary safeSetObjectInDictionary:json object:self.title withKey:@"title"];
	[NSDictionary safeSetObjectInDictionary:json object:self.userName withKey:@"username"];
	[json setValue:[NSNumber numberWithInt:self.created] forKey:@"created"];

    return json;
}


@end

@implementation Utility

+ (NSString *)getContentItemDisplayString:(ContentItem *)item
{
    if (item == nil)
        return @"";
    
    if (item.title != nil && item.title != @"")
        return item.title;
    
    if (item.name != nil && item.name != @"")
        return item.name;
    
    return item.item;
}

@end