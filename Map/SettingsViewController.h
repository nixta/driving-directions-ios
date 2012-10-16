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


/*
 Displays and controls all settings object for the Map Navigator app.
 Sets in motion other view controllers for more advanced settings objects.
 */

@class MapAppSettings;

@interface SettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    UITableView     *_tableView;       
}

@property (nonatomic, strong) IBOutlet UITableView  *tableView;
@property (nonatomic, strong) MapAppSettings        *appSettings;


@end
