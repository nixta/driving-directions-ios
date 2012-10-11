/*
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

#import "Location.h"
#import "LocationBookmark.h"
#import <ArcGIS/ArcGIS.h>
#import "NamedGeometry.h"

@interface LocationBookmark : Location <AGSCoding>
{
    AGSEnvelope *_envelope;
}

@property (nonatomic, strong) AGSEnvelope *envelope;

-(id)initWithLocation:(Location *)location extent:(AGSEnvelope *)extent;

@end
