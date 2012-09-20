//
//  MapViewController+MapTapping.h
//  Map
//
//  Created by Scott Sirowy on 9/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

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
