//
//  SettingsViewController.h
//  Map
//
//  Created by Scott Sirowy on 9/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

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

@property (nonatomic, retain) IBOutlet UITableView  *tableView;
@property (nonatomic, retain) MapAppSettings        *appSettings;
@property (nonatomic, retain) OrganizationChooserViewController *chooserVC;

@end
