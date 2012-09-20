//
//  SignTableView.h
//  StreetSignTest
//
//  Created by Scott Sirowy on 11/17/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

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
