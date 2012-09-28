//
//  Bookmarks.h
//  Map
//
//  Created by Scott Sirowy on 10/10/11.
/*
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */
#import "DrawableList.h"


@class Location;

@interface Bookmarks : DrawableList <AGSCoding>
{
}

-(void)addBookmark:(Location *)bookmark;

@end


