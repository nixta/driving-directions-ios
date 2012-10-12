/*
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

/*
 Protocol so that anything can drawn in a special tableview
 */

@protocol TableViewDrawable <NSObject, AGSCoding>

@property (nonatomic, copy) NSString    *name;

@optional

@property (nonatomic, copy) NSString    *detail;
@property (nonatomic, retain) UIImage   *icon;

-(UITableViewCell *)tableViewCellForTableView:(UITableView *)tableView;

@end
