//
//  AGSDynamicMapServiceLayer+LayerVisibilityAdditions.h
//  ArcGISMobile
//
//  Created by Scott Sirowy on 6/22/11.
//  Copyright 2011 ESRI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ArcGIS+App.h"

@class MapLayerInfo;
@class AGSMapView;
@class AGSWebMapLayerInfo;


@interface AGSDynamicMapServiceLayer (LayerVisibilityAdditions)

-(NSArray *)allVisibleLayersForMapLayerInfo:(AGSWebMapLayerInfo *)mli inMapView:(AGSMapView *)mapView;

@end
