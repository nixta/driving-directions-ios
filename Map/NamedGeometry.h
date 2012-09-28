//
//  NamedGeometry.h
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

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>
#import "TableViewDrawable.h"

@class AGSGeometry;
@class AGSEnvelope;

/*
 An object that subscribes to the 'TableViewDrawable' 
 protocol but that also has a geometry
 */

@protocol NamedGeometry <NSObject, TableViewDrawable>

@property (nonatomic, retain) AGSGeometry *geometry;

@optional

@property (nonatomic, retain) AGSEnvelope *envelope;

@end
