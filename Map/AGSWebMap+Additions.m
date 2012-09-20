//
//  AGSWebMap+Additions.m
//  Map
//
//  Created by Scott Sirowy on 9/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AGSWebMap+Additions.h"
#import "ArcGIS+App.h"


@implementation AGSWebMap (AGSWebMap_Additions)

-(NSString *)title
{
    //return [JSONUtility getStringFromDictionary:self.json withKey:@"title"];
    return @"Web Map Title";
}

-(NSString *)mapIconName
{
    //return [JSONUtility getStringFromDictionary:self.json withKey:@"mapIconName"];
    return @"Web Map Icon Name";
}

@end
