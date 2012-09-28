//
//  SearchFilterHelper.m
//  Map
//
//  Created by Scott Sirowy on 9/16/11.
/*
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

#import "UserSearchResults.h"
#import "Search.h"
#import "Bookmarks.h"
#import "Location.h"
#import "LocationGraphic.h"

#define kPointTargetScale 5000.0

@interface UserSearchResults () 

@property (nonatomic, strong, readwrite) AGSMutableEnvelope *envelope;

-(void)invalidateEnvelope;

@end

@implementation UserSearchResults

@synthesize localCollection = _localCollection;
@synthesize recentSearches = _recentSearches;
@synthesize envelope = _envelope;


- (id)init
{
    return [self initWithRecents:nil localCollection:[DrawableCollection collection]];
}

-(id)initWithRecents:(DrawableList *)recentSearches localCollection:(DrawableCollection *)localCollection
{
    self = [super init];
    if(self)
    {
        self.recentSearches = recentSearches;
        [self addList:self.recentSearches];
        
        self.localCollection = localCollection;
    }
    
    return self;
}

-(void)refineResultsUsingSearchFilter:(NSString *)filterString
{
    //clear old results
    [self clear];
    
    if (filterString == nil || filterString.length == 0) {
        [self addList:self.recentSearches];
        return;
    }
    
    //else, filter all relevant lists
    for (int i = 0; i < [self.localCollection numberOfLists]; i++)
    {
        DrawableList *list = [self.localCollection listAtIndex:i];
        DrawableList *filteredList = [list drawableListFilteredBy:filterString];
        
        //only add back to viewable list if we have some items
        if ([filteredList numberOfItems] > 0)
            [self addList:filteredList];
        
    }
}

-(AGSMutableEnvelope *)envelopeInMapView:(AGSMapView *)mapView
{
    if (_envelope == nil) {
        
        for(int i = 0; i < [self totalNumberOfItems]; i++)
        {
            AGSMutableEnvelope *ftrEnv = nil;
            Location *result = (Location *)[self itemAtIndex:i];
            
            if ([result respondsToSelector:@selector(envelope)]) {
                 ftrEnv = [result.envelope mutableCopy];
            }
            
            if (ftrEnv == nil){
                
                if ([result.geometry isKindOfClass:[AGSPolygon class]] || [result.geometry isKindOfClass:[AGSPolyline class]] ) {
                    ftrEnv = [result.geometry.envelope mutableCopy];
                    [ftrEnv expandByFactor:2];
                }
                else
                {
                    double fRatio = kPointTargetScale / mapView.mapScale;
                    
                    //get a mutable copy of the map current extent, expand by ratio and center at zoomPoint
                    ftrEnv = [mapView.visibleArea.envelope mutableCopy];
                    [ftrEnv expandByFactor:fRatio];
                    [ftrEnv centerAtPoint:result.geometry.envelope.center];
                }
			}
            
            
            if (_envelope == nil){
                self.envelope = [AGSMutableEnvelope envelopeWithXmin:ftrEnv.xmin 
                                                            ymin:ftrEnv.ymin 
                                                            xmax:ftrEnv.xmax 
                                                            ymax:ftrEnv.ymax 
                                                spatialReference:mapView.spatialReference];
            }
            else {
                [_envelope unionWithEnvelope:ftrEnv];
            }
            
        }
        
        [_envelope expandByFactor:1.2];
    }
    
    return _envelope;
}

-(void)addResultsToLayer:(AGSGraphicsLayer *)graphicsLayer
{
    for(int i = 0 ; i < [self totalNumberOfItems]; i++)
    {
        Location *result = (Location *)[self itemAtIndex:i];
        
        if([result hasValidPoint])
            [graphicsLayer addGraphic:result.graphic];
    }
}

#pragma mark -
#pragma mark Collection Method Overrides
-(void)addList:(DrawableList *)list
{
    [super addList:list];
    [self invalidateEnvelope];
}

-(void)removeListAtIndex:(NSUInteger)index
{
    [super removeListAtIndex:index];
    [self invalidateEnvelope];
}

-(void)removeListWithName:(NSString *)name
{
    [super removeListWithName:name];
    [self invalidateEnvelope];
}
-(void)clear
{
    [super clear];
    [self invalidateEnvelope];
}

-(void)invalidateEnvelope
{
    self.envelope = nil;
}

@end
