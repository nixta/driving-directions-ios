//
//  MapViewController+Search.h
//  Map
//
//  Created by Scott Sirowy on 10/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"

/*
 Category for all search related tasks on the map view.
 */

@interface MapViewController (Search) <UISearchBarDelegate, GeocodeServiceDelegate, LocationDelegate>

-(void)dropPinForSearchLocation:(Location *)location;
-(void)dropPinForSearchLocation:(Location *)location zoomToLocation:(BOOL)zoom;
-(void)dropPinForSearchLocation:(Location *)location zoomToLocation:(BOOL)zoom showCallout:(BOOL)showCallout;

-(void)setupSearchUx;
-(void)setSearchState:(MapSearchState)state withKeyboard:(BOOL)keyboard animated:(BOOL)animated;

-(void)mapListButtonPressed:(id)sender;

-(void)searchFinishedExecuting;

@end
