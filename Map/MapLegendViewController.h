/*
 MapLegendViewController.h
 ArcGISMobile
 COPYRIGHT 2011 ESRI
 
 TRADE SECRETS: ESRI PROPRIETARY AND CONFIDENTIAL
 Unpublished material - all rights reserved under the
 Copyright Laws of the United States and applicable international
 laws, treaties, and conventions.
 
 For additional information, contact:
 Environmental Systems Research Institute, Inc.
 Attn: Contracts and Legal Services Department
 380 New York Street
 Redlands, California, 92373
 USA
 
 email: contracts@esri.com
 */

#import <UIKit/UIKit.h>
//#import "Legend.h"

@class MapAppDelegate;

@interface MapLegendViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *_tableView;
    
    UIView  *_activityIndicatorView;
    UIActivityIndicatorView *_activityIndicator;
    
    @private
    MapAppDelegate *_app;
    BOOL _legendNeedsToBeRegenerated;
}

/*IBOutlets to UI components in IB */
@property (nonatomic, retain) IBOutlet UITableView *tableView;

/*Shown when media is downloading */
@property (nonatomic, retain) UIView *activityIndicatorView;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;

-(void)generateLegend;
-(void)legendShouldBeRedrawn:(id)sender;

@end

