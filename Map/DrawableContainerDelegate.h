//
//  NamedGeometryContainerDelegate.h
//  Map
//
//  Created by Scott Sirowy on 9/15/11.
//  Copyright 2011 ESRI. All rights reserved.
//
/*
 WIArrowCalloutView.m
 Westerville Inspection Demo -- Esri 2012 Dev Summit
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

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
