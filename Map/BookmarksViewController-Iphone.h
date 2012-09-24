/*
 BookmarksViewController-Iphone.h
 ArcGISMobile
 
 COPYRIGHT 2011 ESRI
 
 TRADE SECRETS: ESRI PROPRIETARY AND CONFIDENTIAL
 Unpublished material - all rights reserved under the
 Copyright Laws of the United States and applicable international
 laws, treaties, and conventions.
 
 For additional information, contact:
 Environmental Systems Research Institute, Inc.
 Attn: Contracts and Legal Services Department
 380 New York Street
 Redlands, California, 92373
 USA
 
 email: contracts@esri.com
 */


/*
 Subclass of BookmarksViewController meant for iPhone
 */

#import <UIKit/UIKit.h>
#import "BookmarksViewController.h"


@interface BookmarksViewController_Iphone : BookmarksViewController 
{
   UIBarButtonItem *_mapButton;
}

/* button to get back to main map page  */
@property (nonatomic, strong) UIBarButtonItem *mapButton;

@end
