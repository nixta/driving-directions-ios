/*
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

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
