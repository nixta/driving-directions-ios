//
//  MapViewController+PlanningRouting.h
//  Map
//
//  Created by Scott Sirowy on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"
#import "DrawableContainerDelegate.h"

/*
 Category for all planning/routing related methods
 */

@interface MapViewController (PlanningRouting) <DrawableContainerDataSource, EditableSignsDelegate>

-(void)showDirectionsSigns:(BOOL)show directions:(DirectionsList *)directions;
-(void)showStopSigns:(BOOL)show;

@end
