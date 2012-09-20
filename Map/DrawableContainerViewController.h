//
//  ResultsContainerViewController.h
//  Map
//
//  Created by Scott Sirowy on 9/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawableContainerDelegate.h"

@class ArcGISAppDelegate;

/*
 Generic way of a showing elements in a tableview. Can show objects that
 can be drawn (as defined by the TableViewDrawable protocol) in a tableview, 
 and returns them when user taps one
 */

@interface DrawableContainerViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    UITableView                     *_tableView;
    UIToolbar                       *_toolbar;
    
    id<DrawableContainerDelegate>   _delegate;
    id<DrawableContainerDataSource> _datasource;
    
    @private
    ArcGISAppDelegate               *_app;
    BOOL                            _showToolbar;
    BOOL                            _highlightCurrentIndex;
    BOOL                            _tableViewMinimized;
}

/*Main UX elements from Interface builder */
@property (nonatomic, retain) IBOutlet UITableView              *tableView;

/*Misc. Ux elements */
@property (nonatomic, retain) IBOutlet UIToolbar                *toolbar;

@property (nonatomic, assign) id<DrawableContainerDelegate>     delegate;
@property (nonatomic, assign) id<DrawableContainerDataSource>   datasource;

@property (nonatomic, assign) BOOL                              highlightCurrentIndex;

@property (nonatomic, assign) BOOL                              showToolbar;

-(id)initWithToolbar:(BOOL)showToolbar;

/*Call to update the status of the search results */
-(void)refineSearchResults;

//Call to min/max accounting for a keyboard
-(void)minimize;
-(void)maximize;

@end
