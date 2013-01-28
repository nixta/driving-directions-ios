/*
 Copyright © 2013 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

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
    
    NSArray                     *_mapLayerViews;
    BasemapsTableViewCell       *_basemapsTableViewCell;
    
    SettingsViewController      *_settingsVC;
    NSMutableArray              *_layersArray;
    UIView                      *_waitingView;
    UIActivityIndicatorView     *_activityIndicator;
    BOOL                        _waitingForBasemapToChange;
}

/*Interface Builder Ux Elements */
@property (nonatomic, strong) IBOutlet UITableView          *tableView;
@property (nonatomic, strong) IBOutlet UINavigationBar      *navBar;
@property (nonatomic, strong) IBOutlet UINavigationItem     *navItem;
@property (nonatomic, strong) IBOutlet UIView               *settingsView;
@property (nonatomic, strong) IBOutlet UILabel              *signInLabel;

/*Misc. UX Elements */
@property (nonatomic, strong) UIBarButtonItem               *mapButton;

@property (nonatomic, strong) UIBarButtonItem               *settingsButton;

@property (nonatomic, strong) id<ChangeBasemapsDelegate>    changeBasemapDelegate;

@property (nonatomic, strong) NSArray                       *mapLayerViews;

@property (nonatomic, strong) AGSMapView                    *mapView;

-(IBAction)settingsButtonTapped:(id)sender;

/*This should be changed to pass in operational layers at some point, but for now
 works for proof of concept
 */
-(id)initWithMapLayerViews:(NSDictionary *)mapLayerViews;
-(id)initWithMap:(AGSMapView *)mapView;

/*Message passed to indicate basemap has successfully been changed somewhere in the app */
-(void)successfullyChangedBasemap;

@end
