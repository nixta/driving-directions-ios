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

@interface AGSWebMapLayerInfo (AppAdditions)

-(BOOL)isGroupLayer:(NSInteger)layerID inMapView:(AGSMapView *)mapView;
-(BOOL)isGroupLayer:(AGSMapView *)mapView;
-(BOOL)getSubLayerCount:(AGSMapView *)mapView;
-(BOOL)isDynamicMapService:(AGSMapView *)mapView;
-(AGSMapServiceInfo *)getMSI:(AGSMapView *)mapView;
-(AGSDynamicMapServiceLayer *)getDynamicMapServiceLayer:(AGSMapView *)mapView;
-(AGSTiledMapServiceLayer *)getTiledMapServiceLayer:(AGSMapView *)mapView;

@end
