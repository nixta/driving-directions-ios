//
//  UserSearchResults.h
//  Map
//
//  Created by Scott Sirowy on 9/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DrawableContainerDelegate.h"
#import "DrawableCollection.h"

/*
 User Search Results is meant as a data source method 
 for filtering search results for a Container class that
 can display them.
 
 Class collects various search results, including
 bookmarks, contacts, addresses, and places.
 */

@interface UserSearchResults : DrawableCollection
{
    DrawableList        *_recentSearches;
    DrawableCollection  *_localCollection;
    AGSMutableEnvelope  *_envelope;
}

@property (nonatomic, retain) DrawableList          *recentSearches;
@property (nonatomic, retain) DrawableCollection    *localCollection;

-(id)initWithRecents:(DrawableList *)recentSearches localCollection:(DrawableCollection *)localCollection;

-(void)refineResultsUsingSearchFilter:(NSString *)filterString;

-(AGSEnvelope *)envelopeInMapView:(AGSMapView *)mapView;
-(void)addResultsToLayer:(AGSGraphicsLayer *)graphicsLayer;

@end
