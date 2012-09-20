//
//  DirectionsPrintRenderer.h
//  Map
//
//  Created by Scott Sirowy on 10/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

/*
 Page renderer for printing a list of directions.
 */

#import <UIKit/UIKit.h>

@class DirectionsList;

@interface DirectionsPrintRenderer : UIPrintPageRenderer
{
    DirectionsList *_directions;
}

@property (nonatomic, retain) DirectionsList *directions;

-(id)initWithDirections:(DirectionsList *)list;

@end
