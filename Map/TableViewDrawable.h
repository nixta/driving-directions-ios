//
//  TableViewDrawable.h
//  Map
//
//  Created by Scott Sirowy on 9/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ArcGIS+App.h"

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
