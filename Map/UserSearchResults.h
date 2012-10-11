/*
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

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

@property (nonatomic, strong) DrawableList          *recentSearches;
@property (nonatomic, strong) DrawableCollection    *localCollection;

-(id)initWithRecents:(DrawableList *)recentSearches localCollection:(DrawableCollection *)localCollection;

-(void)refineResultsUsingSearchFilter:(NSString *)filterString;

-(AGSEnvelope *)envelopeInMapView:(AGSMapView *)mapView;
-(void)addResultsToLayer:(AGSGraphicsLayer *)graphicsLayer;

@end
