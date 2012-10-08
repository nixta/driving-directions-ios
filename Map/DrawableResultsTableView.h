//
//  DrawableResultsTableView.h
//  Map
//
//  Created by Scott Sirowy on 11/30/11.
/*
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

#import <UIKit/UIKit.h>
#import "DrawableContainerDelegate.h"

@class DrawableCollection;

/*
 Tableview that can draw a list/collection of 'TableViewDrawable' objects
 */

@interface DrawableResultsTableView : UITableView <UITableViewDataSource, UITableViewDelegate>
{
    id<DrawableContainerDelegate>   __unsafe_unretained _resultsDelegate;
    id<DrawableContainerDataSource> _drawableDataSource;
    
    @private
    BOOL                            _tableViewMinimized;
}

@property (nonatomic, strong) id<DrawableContainerDataSource> resultsDataSource;
@property (nonatomic, unsafe_unretained) id<DrawableContainerDelegate> resultsDelegate;

-(void)minimize;
-(void)maximize;

@end
