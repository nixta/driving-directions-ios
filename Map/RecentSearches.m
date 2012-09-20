//
//  RecentSearches.m
//  Map
//
//  Created by Scott Sirowy on 10/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RecentSearches.h"
#import "Search.h"

@interface DrawableList () 

@property (nonatomic, retain, readwrite) NSMutableArray  *items;

@end


@implementation RecentSearches

#pragma mark -
#pragma mark AGSCoding
- (void)decodeWithJSON:(NSDictionary *)json
{
    [super decodeWithJSON:json];
    
    self.items = [AGSJSONUtility decodeFromDictionary:json withKey:@"searches" fromClass:[Search class]];
}

- (NSDictionary *)encodeToJSON
{
    NSMutableDictionary *json = (NSMutableDictionary *)[super encodeToJSON];
    
    [AGSJSONUtility encodeToDictionary:json withKey:@"searches" AGSCodingArray:self.items];
    
    return json;
}

@end
