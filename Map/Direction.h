//
//  Direction.h
//  Map
//
//  Created by Scott Sirowy on 9/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NamedGeometry.h"
#import "ArcGIS+App.h"

/*
 Alternate organization of the AGSDirectionGraphic
 */

@protocol DirectionDelegate;

@interface Direction : NSObject <NamedGeometry, AGSExportMapImageDelegate>
{
    AGSGeometry             *_geometry;
    NSString                *_name;
    UIImage                 *_icon;
    UIImage                 *_mapImage;
    NSString                *_distanceString;
    NSString                *_etaString;
    NSString                *_abbreviatedName;
    
    id<DirectionDelegate>   _delegate;
}

@property (nonatomic, retain) AGSGeometry               *geometry;
@property (nonatomic, copy)   NSString                  *name;
@property (nonatomic, retain) UIImage                   *icon;
@property (nonatomic, retain) UIImage                   *mapImage;
@property (nonatomic, copy) NSString                    *distanceString;
@property (nonatomic, copy) NSString                    *etaString;
@property (nonatomic, copy) NSString                    *abbreviatedName;
@property (nonatomic, assign) id<DirectionDelegate>     delegate;

-(id)initWithDirectionGraphic:(AGSDirectionGraphic *)directionGraphic;
-(void)retrieveMapImageOfSize:(CGSize)size;

+(NSString *)stringForDistance:(double)length;
+(NSString *)stringForMinutes:(double)time;

@end

@protocol DirectionDelegate <NSObject>

@optional

-(void)direction:(Direction *)dir didRetrieveMapImage:(UIImage *)directionImage;
-(void)directionDidFailToRetrieveImage:(Direction *)dir;

@end
