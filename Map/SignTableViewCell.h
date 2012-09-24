//
//  SignTableViewCell.h
//  Map
//
//  Created by Scott Sirowy on 11/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

/*
 A tableview cell for the SignTableView
 */

#import <UIKit/UIKit.h>

@interface SignTableViewCell : UITableViewCell
{
    UIView      *_view;
    UIImageView *_iconImageView;
    UILabel     *_nameLabel;
    UILabel     *_distanceLabel;
    
    BOOL        _isCurrentLocation;
}

@property (nonatomic, strong) UIView        *view;
@property (nonatomic, strong) UIImageView   *iconImageView;
@property (nonatomic, strong) UILabel       *nameLabel;
@property (nonatomic, strong) UILabel       *distanceLabel;
@property (nonatomic, assign) BOOL          isCurrentLocation;

@end
