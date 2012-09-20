//
//  PopupView.h
//  TestPopup
//
//  Created by Scott Sirowy on 1/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BlankSignView.h"

@interface PopupFrontView : BlankSignView <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *_tableview;
}

@property (nonatomic, retain) UITableView *tableview;

@end
