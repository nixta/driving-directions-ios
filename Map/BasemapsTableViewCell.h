//
//  BasemapsTableViewCell.h
//  Map
//
//  Created by Scott Sirowy on 9/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 A blank tableview cell that has a view to add a basemaps view to
 */

@interface BasemapsTableViewCell : UITableViewCell
{
    UIView *_view;
}

@property (nonatomic, retain) IBOutlet UIView *view;

@end
