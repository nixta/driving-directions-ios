//
//  AGSGeometry+AppAdditions.h
//  ArcGISMobile
//
//  Created by ryan3374 on 12/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>

@interface AGSGeometry (AppAdditions)

-(BOOL)isEmpty;
-(AGSPoint *)getLocationPoint;
-(AGSGeometryType)geometryType;
-(AGSPoint *)head;

@end
