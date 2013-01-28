/*
 Copyright © 2013 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

#import <UIKit/UIKit.h>

/*
 A blank tableview cell that has a view to add a basemaps view to
 */

@interface BasemapsTableViewCell : UITableViewCell
{
    UIView *_view;
}

@property (nonatomic, strong) IBOutlet UIView *view;

@end
