/*
 Copyright © 2013 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

#import "LocationGraphic.h"
#import "Location.h"

@implementation LocationGraphic

-(id)initWithGeometry:(AGSGeometry *)geometry symbol:(AGSSymbol *)symbol attributes:(NSMutableDictionary *)attributes infoTemplateDelegate:(id<AGSInfoTemplateDelegate>)infoTemplateDelegate
{
    return [super initWithGeometry:geometry symbol:symbol attributes:attributes infoTemplateDelegate:infoTemplateDelegate];
}

-(void)clearLocation
{
    self.location = nil;
}

@end
