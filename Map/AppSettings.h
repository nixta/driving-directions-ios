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

@class ArcGISOnlineConnection;

@interface AppSettings : NSObject <AGSCoding>
{
    ArcGISOnlineConnection  *_arcGISOnlineConnection;
}

@property (nonatomic, strong) ArcGISOnlineConnection    *arcGISOnlineConnection;

@end
