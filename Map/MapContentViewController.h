//
//  MapContentViewController.h
//  Map
//
//  Created by Scott Sirowy on 8/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SectionHeaderView.h"
#import "BasemapsViewController.h"
#import "Legend.h"

@class ArcGISAppDelegate;
@class BasemapsViewController;
@class BasemapsTableViewCell;
@class SettingsViewController;

/*
 Class MapContentViewController is really just a container for
 showing the Layers content and flipping back and forth
 to the Map Legend
 */

@interface MapContentViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, 
                                                        SectionHeaderViewDelegate, ChangeBasemapsDelegate, LegendDelegate>
{
    UITableView                 *_tableView;
    UINavigationBar             *_navBar;
    UINavigationItem            *_navItem;
    UIView                      *_settingsView;
    UILabel                     *_signInLabel;
    
    UIBarButtonItem             *_mapButton;
    UIBarButtonItem             *_settingsButton;
    
    id<ChangeBasemapsDelegate>  _changeBasemapDelegate;
    
    @private
    
    NSDictionary                *_mapLayerViews;
    BasemapsTableViewCell       *_basemapsTableViewCell;
    BasemapsViewController      *_basemapsVC;
    SettingsViewController      *_settingsVC;
    NSMutableArray              *_layersArray;
    UIView                      *_waitingView;
    UIActivityIndicatorView     *_activityIndicator;
    BOOL                        _waitingForBasemapToChange;
}

/*Interface Builder Ux Elements */
@property (nonatomic, retain) IBOutlet UITableView          *tableView;
@property (nonatomic, retain) IBOutlet UINavigationBar      *navBar;
@property (nonatomic, retain) IBOutlet UINavigationItem     *navItem;
@property (nonatomic, retain) IBOutlet UIView               *settingsView;
@property (nonatomic, retain) IBOutlet UILabel              *signInLabel;

/*Misc. UX Elements */
@property (nonatomic, retain) UIBarButtonItem               *mapButton;
@property (nonatomic, retain) UIBarButtonItem               *settingsButton;

@property (nonatomic, assign) id<ChangeBasemapsDelegate>    changeBasemapDelegate;

-(IBAction)settingsButtonTapped:(id)sender;

/*This should be changed to pass in operational layers at some point, but for now
 works for proof of concept
 */
-(id)initWithMapLayerViews:(NSDictionary *)mapLayerViews;

/*Message passed to indicate basemap has successfully been changed somewhere in the app */
-(void)successfullyChangedBasemap;

@end
