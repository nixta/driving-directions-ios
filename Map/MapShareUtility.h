//
//  MapShareUtility.h
//  Map
//
//  Created by Scott Sirowy on 10/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

/*
 Class that can parse data embedded in URL link or in file to share
 within the app... 
 
 The two types of sharing are:
 1. Location sharing
 2. Route sharing
 */

#import <Foundation/Foundation.h>
#import "ArcGIS+App.h"

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
