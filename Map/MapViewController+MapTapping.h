//
//  MapViewController+MapTapping.h
//  Map
//
//  Created by Scott Sirowy on 9/14/11.
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
 Category to separate the MapViewTouchDelegate methods, as well
 as any related map tapping methods away from the MapViewController
 */

#import "MapViewController.h"

@class ContactLocationBookmark;
@class Location;

@interface MapViewController (MapViewController_MapTapping) <InputAlertViewDelegate, AGSPopupsContainerDelegate>

-(Location *)defaultLocationForPoint:(AGSPoint *)point;
-(void)dropPinForLocation:(Location *)location;

-(void)showCalloutForLocation:(Location *)location;

-(void)setCalloutShown:(BOOL)shown;

-(void)wantBookmarkForLocation:(Location *)location;

-(BOOL)canMakePhoneCalls;
-(void)makePhoneCallForContactLocation:(ContactLocationBookmark *)location;

@end
