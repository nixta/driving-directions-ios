//
//  StreetSignView.h
//  StreetSignTest
//
//  Created by Scott Sirowy on 11/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

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

@property (nonatomic, retain) Direction *direction;

-(id)initWithFrame:(CGRect)frame withDirection:(Direction *)direction withReflectionSlope:(CGFloat)slope startingX:(CGFloat)x useShadow:(BOOL)useShadow;

@end
