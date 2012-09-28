//
//  AGSWebMap+Additions.m
//  Map
//
//  Created by Scott Sirowy on 9/19/11.
/*
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

#import "AGSWebMap+Additions.h"
#import <ArcGIS/ArcGIS.h>


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
