//
//  SignTableView.h
//  StreetSignTest
//
//  Created by Scott Sirowy on 11/17/11.
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
#import "BlankSignView.h"

/*
 Wrapper for a tableview that looks like a large street sign
 */

@interface SignTableView : BlankSignView
{
    UITableView *_tableView;
}

-(id)initWithFrame:(CGRect)frame dataSource:(id<UITableViewDataSource>)dataSource delegate:(id<UITableViewDelegate>)delegate;
-(void)reloadData;
-(void)setEditing:(BOOL)editing animated:(BOOL)animated;
-(void)deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;
-(void)setDataSource:(id<UITableViewDataSource>)dataSource;
-(void)setDelegate:(id<UITableViewDelegate>)delegate;
@end
