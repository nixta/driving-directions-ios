/*
 Copyright © 2013 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

#import <ArcGIS/ArcGIS.h>

@class Location;

/*
 Subclass of graphic that includes the graphic's location.
 */

@interface LocationGraphic : AGSGraphic
{
    Location *__unsafe_unretained _location;
}

@property (nonatomic, unsafe_unretained) Location *location;

-(void)clearLocation;

@end
