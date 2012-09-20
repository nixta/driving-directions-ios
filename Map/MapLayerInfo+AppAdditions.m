//
//  MapLayerInfo+AppAdditions.m
//  ArcGISMobile
//
//  Created by Mark Dostal on 1/25/11.
//  Copyright 2011 ESRI. All rights reserved.
//

#import "MapLayerInfo+AppAdditions.h"
#import "ArcGIS+App.h"

@interface AGSWebMapLayerInfo ()

-(AGSMapServiceInfo *)getMSI:(AGSMapView *)mapView;

@end

@implementation AGSWebMapLayerInfo (AppAdditions)

-(BOOL)isGroupLayer:(NSInteger)layerID inMapView:(AGSMapView *)mapView
{
    BOOL bIsGroupLayer = NO;
    AGSMapServiceInfo *msi = [self getMSI:mapView];
    if (msi)
    {
        NSArray *layerInfos = msi.layerInfos;
        if (layerInfos && [layerInfos count] > 0)
        {
            for (AGSMapServiceLayerInfo *msli in layerInfos) {
                //there is a layer who's parent layer is our layer,
                //so our layer is a parent layer
                if (msli.parentLayerID == layerID)
                {
                    bIsGroupLayer = YES;
                    break;
                }
            }
        }
    }
    else if (self.featureCollection)
    {
        NSArray *layerInfos = self.featureCollection.layers;
        bIsGroupLayer = (layerInfos && [layerInfos count] > 0);
    }
    
    return bIsGroupLayer;
}

-(BOOL)isGroupLayer:(AGSMapView *)mapView
{
    BOOL bIsGroupLayer = NO;
    AGSMapServiceInfo *msi = [self getMSI:mapView];
    if (msi)
    {
        NSArray *layerInfos = msi.layerInfos;
        bIsGroupLayer = (layerInfos && [layerInfos count] > 0);
    }
    else if (self.featureCollection)
    {
        NSArray *layerInfos = self.featureCollection.layers;
        bIsGroupLayer = (layerInfos && [layerInfos count] > 0);
    }
    
    return bIsGroupLayer;
}

-(BOOL)getSubLayerCount:(AGSMapView *)mapView
{
    NSInteger subLayerCount = 0;
    AGSMapServiceInfo *msi = [self getMSI:mapView];
    if (msi)
    {
        NSArray *layerInfos = msi.layerInfos;
        if (layerInfos)
        {
            subLayerCount = [layerInfos count];
        }        
    }
    else if (self.featureCollection)
    {
        subLayerCount = [self.featureCollection.layers count];
    }
    
    return subLayerCount;
}

-(AGSMapServiceInfo *)getMSI:(AGSMapView *)mapView
{
    //get the AGSLayerView for our layer
    id<AGSLayerView> layerView = [mapView.mapLayerViews objectForKey:self.title];
    
    //if we can't find the layer, return nil
    if (!layerView)
        return nil;
    
    //get the AGSLayer
    AGSLayer *layer = layerView.agsLayer;
    
    AGSMapServiceInfo *msi = nil;
    
    //only AGSTiledMapServiceLayers or AGSDynamicMapServiceLayer have AGSMapServiceInfos
    if ([layer isKindOfClass:[AGSTiledMapServiceLayer class]])
    {
        //get the AGSMapServiceInfo for our layer
        msi = ((AGSTiledMapServiceLayer *)layer).mapServiceInfo;
    }
    else if ([layer isKindOfClass:[AGSDynamicMapServiceLayer class]])
    {
        //get the AGSMapServiceInfo for our layer
        msi = ((AGSDynamicMapServiceLayer *)layer).mapServiceInfo;
    }
    
    return msi;
}

-(BOOL)isDynamicMapService:(AGSMapView *)mapView
{
    //get the AGSLayerView for our layer
    id<AGSLayerView> layerView = [mapView.mapLayerViews objectForKey:self.title];
    
    if (!layerView)
        return NO;
    
    //get the AGSLayer
    AGSLayer *layer = layerView.agsLayer;
    
    BOOL bIsDynamicMapService = [layer isKindOfClass:[AGSDynamicMapServiceLayer class]];
    
    return bIsDynamicMapService;
}

-(AGSDynamicMapServiceLayer *)getDynamicMapServiceLayer:(AGSMapView *)mapView
{
    id<AGSLayerView> layerView = [mapView.mapLayerViews objectForKey:self.title];
    
    if (!layerView)
        return nil;
    
    //get the AGSLayer
    AGSLayer *layer = layerView.agsLayer;
    
    AGSDynamicMapServiceLayer *retValue = nil;
    if ([layer isKindOfClass:[AGSDynamicMapServiceLayer class]])
    {
        retValue = (AGSDynamicMapServiceLayer *)layer;
    }
    
    return retValue;
}

-(AGSTiledMapServiceLayer *)getTiledMapServiceLayer:(AGSMapView *)mapView
{
    id<AGSLayerView> layerView = [mapView.mapLayerViews objectForKey:self.title];
    
    if (!layerView)
        return nil;
    
    //get the AGSLayer
    AGSLayer *layer = layerView.agsLayer;
    
    AGSTiledMapServiceLayer *retValue = nil;
    if ([layer isKindOfClass:[AGSTiledMapServiceLayer class]])
    {
        retValue = (AGSTiledMapServiceLayer *)layer;
    }
    
    return retValue;
}

@end
