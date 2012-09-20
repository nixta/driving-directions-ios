//
//  TabbedResultsViewController.h
//  Map
//
//  Created by Scott Sirowy on 9/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

/*
 Tabbed results view controller that includes for support for a "blinds" like
 animation for opening and closing the set of drawable results
 */

typedef enum {
    TabbedStateHidden = 0,
    TabbedStateClosed,
    TabbedStateOpen
} TabbedResultsState;

#import "DrawableContainerViewController.h"


@protocol TabbedResultsDelegate;

@interface TabbedResultsViewController : DrawableContainerViewController
{
    id<TabbedResultsDelegate>   _tabDelegate;
    
    @private
    UIButton                    *_tabButton;
    TabbedResultsState          _state;
}

@property (nonatomic, assign) id<TabbedResultsDelegate> tabDelegate;

-(id)initWithTabState:(TabbedResultsState)state;
-(void)setTabState:(TabbedResultsState)state animated:(BOOL)animated;

@end

@protocol TabbedResultsDelegate <NSObject>

@optional

-(void)tabbedResultsViewController:(TabbedResultsViewController *)trvc didChangeToState:(TabbedResultsState)state;

@end
