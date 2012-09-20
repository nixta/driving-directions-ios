//
//  DrawableResultsTableView.h
//  Map
//
//  Created by Scott Sirowy on 11/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawableContainerDelegate.h"

@class DrawableCollection;

/*
 Tableview that can draw a list/collection of 'TableViewDrawable' objects
 */

@interface DrawableResultsTableView : UITableView <UITableViewDataSource, UITableViewDelegate>
{
    id<DrawableContainerDelegate>   _resultsDelegate;
    id<DrawableContainerDataSource> _drawableDataSource;
    
    @private
    BOOL                            _tableViewMinimized;
}

@property (nonatomic, assign) id<DrawableContainerDataSource> resultsDataSource;
@property (nonatomic, assign) id<DrawableContainerDelegate> resultsDelegate;

-(void)minimize;
-(void)maximize;

@end
