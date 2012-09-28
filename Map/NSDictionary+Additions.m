//
//  NSDictionary+Additions.m
//  Map
//
//  Created by Scott Sirowy on 9/12/11.
/*
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

#import "NSDictionary+Additions.h"

@implementation NSDictionary (NSDictionary_Additions)

+(id)safeGetObjectFromDictionary:(NSDictionary *)dict
                         withKey:(NSString *)key
{
	id obj = [dict objectForKey:key];
	if ((NSNull*)obj == [NSNull null])
	{
		obj = nil;
	}
    
	return obj;    
}

+(void)safeSetObjectInDictionary:(NSMutableDictionary *)dict
                          object:(NSObject *)object
                         withKey:(NSString *)key
{
	if (object == nil){
		[dict setObject:[NSNull null] forKey:key];
	}
	else {
		[dict setObject:object forKey:key];
	}
}


@end
