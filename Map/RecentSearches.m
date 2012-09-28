//
//  RecentSearches.m
//  Map
//
//  Created by Scott Sirowy on 10/21/11.
/*
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

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
