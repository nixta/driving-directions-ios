//
//  StreetSignView.h
//  StreetSignTest
//
//  Created by Scott Sirowy on 11/7/11.
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
 Sign that shows a direction on a route
 */

#import <UIKit/UIKit.h>
#import "BlankSignView.h"

@class Direction;

@interface StreetSignView : BlankSignView
{
    Direction   *_direction;
}

@property (nonatomic, strong) Direction *direction;

-(id)initWithFrame:(CGRect)frame withDirection:(Direction *)direction withReflectionSlope:(CGFloat)slope startingX:(CGFloat)x useShadow:(BOOL)useShadow;

@end
