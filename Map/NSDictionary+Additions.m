//
//  NSDictionary+Additions.m
//  Map
//
//  Created by Scott Sirowy on 9/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

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
