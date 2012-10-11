/*
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */
/*
 Class that can parse data embedded in URL link or in file to share
 within the app... 
 
 The two types of sharing are:
 1. Location sharing
 2. Route sharing
 */

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

typedef enum {
    MapShareInterfaceShareLocation,
    MapShareInterfaceShareRoute,
} MapShareInterfaceType;

@class Location;
@class Route;

@interface MapShareUtility : NSObject
{
    MapShareInterfaceType   shareType;
    
    Route                   *_route;
    Location                *_shareLocation;
    
    NSString                *_callbackString;
}

@property (nonatomic, assign, readonly) MapShareInterfaceType   shareType;

@property (nonatomic, strong, readonly) Route                   *route;
@property (nonatomic, strong, readonly) Location                *shareLocation;

@property (nonatomic, copy) NSString                            *callbackString;

/*
 Straight string coming from a custom url... 
 */
-(id)initWithUrl:(NSURL *)url withSpatialReference:(AGSSpatialReference *)sr locatorURL:(NSURL *)locatorURL;

+(NSString *)urlStringForRoute:(Route *)route;
+(NSString *)urlStringForSharingLocation:(Location *)location;

@end
