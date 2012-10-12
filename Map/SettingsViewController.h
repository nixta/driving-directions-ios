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
#import "OrganizationChooserViewController.h"

/*
 Displays and controls all settings object for the Map Navigator app.
 Sets in motion other view controllers for more advanced settings objects.
 */

@class MapAppSettings;

@interface SettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, OrganizationChooserDelegate>
{
    UITableView     *_tableView;
    MapAppSettings  *appSettings;
    OrganizationChooserViewController *_chooserVC;
}

@property (nonatomic, strong) IBOutlet UITableView  *tableView;
@property (nonatomic, strong) MapAppSettings        *appSettings;
@property (nonatomic, strong) OrganizationChooserViewController *chooserVC;

@end
