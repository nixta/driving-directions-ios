//
//  NamedGeometryContainerDelegate.h
//  Map
//
//  Created by Scott Sirowy on 9/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TableViewDrawable.h"

@class DrawableContainerViewController;
@class DrawableList;

/*
 A datasource for objects that are 'Drawable" as defined by
 the 'TableViewDrawable' protocol. 
 */

@protocol DrawableContainerDataSource <NSObject>

-(NSUInteger)numberOfResultTypes;    //i.e number of sections
-(NSUInteger)numberOfResultsInSection:(NSUInteger)section;
-(NSString *)titleOfResultTypeForSection:(NSUInteger)section;
-(id<TableViewDrawable>)resultForRowAtIndexPath:(NSIndexPath *)index;
-(BOOL)canMoveResultAtIndexPath:(NSIndexPath *)index;
-(DrawableList *)listForSection:(NSUInteger)section;

@optional
-(NSUInteger)selectedResultIndex;
-(NSArray *)sectionTitles;

@end

/*
 Delegate for DrawableContainerViewController
 */

@protocol DrawableContainerDelegate <NSObject>

@optional
-(void)viewController:(id)viewController didClickOnResult:(id<TableViewDrawable>)result;

@end
