//
//  AGSGeometry+AppAdditions.h
//  ArcGISMobile
//
//  Created by ryan3374 on 12/9/10.
/*
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

#import <ArcGIS/ArcGIS.h>

@interface AGSGeometry (AppAdditions)

-(BOOL)isEmpty;
-(AGSPoint *)getLocationPoint;
-(AGSGeometryType)geometryType;
-(AGSPoint *)head;

@end
