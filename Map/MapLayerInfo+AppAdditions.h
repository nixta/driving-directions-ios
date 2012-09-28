//
//  MapLayerInfo+AppAdditions.h
//  ArcGISMobile
//
//  Created by Mark Dostal on 1/25/11.
//  Copyright 2011 ESRI. All rights reserved.
//
#import <ArcGIS/ArcGIS.h>

@interface AGSWebMapLayerInfo (AppAdditions)

-(BOOL)isGroupLayer:(NSInteger)layerID inMapView:(AGSMapView *)mapView;
-(BOOL)isGroupLayer:(AGSMapView *)mapView;
-(BOOL)getSubLayerCount:(AGSMapView *)mapView;
-(BOOL)isDynamicMapService:(AGSMapView *)mapView;
-(AGSMapServiceInfo *)getMSI:(AGSMapView *)mapView;
-(AGSDynamicMapServiceLayer *)getDynamicMapServiceLayer:(AGSMapView *)mapView;
-(AGSTiledMapServiceLayer *)getTiledMapServiceLayer:(AGSMapView *)mapView;

@end
