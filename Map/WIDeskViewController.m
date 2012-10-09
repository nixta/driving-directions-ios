/*
 WIViewController.m
 Westerville Inspection Demo -- Esri 2012 Dev Summit
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */


#import <ArcGIS/ArcGIS.h>

#import <QuartzCore/QuartzCore.h>
#import "WIDeskViewController.h"
#import "Organization.h"



@implementation WIDeskViewController

@synthesize portal = _portal;
@synthesize webMap = _webMap;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //credential. Add your own credential if you want to hit a non-public map 
    //on your own account
    AGSCredential *cred = nil;
    
    //create new portal
    NSURL *portalUrl = [NSURL URLWithString:@"http://arcgis.com"];
    AGSPortal *newPortal = [[AGSPortal alloc] initWithURL:portalUrl credential:cred];
    newPortal.delegate = self;
    self.portal = newPortal;
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //
    // limit our application to a landscape orientation
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}



#pragma mark -
#pragma mark AGSPortalDelegate
-(void)portalDidLoad:(AGSPortal*)portal
{
    //Create a new webmap using the new portal
    AGSWebMap *newWebmap = [AGSWebMap webMapWithItemId:kDefaultWebMapId portal:self.portal];
    newWebmap.delegate = self;
    self.webMap = newWebmap;
    
    //Go grab basemaps in the background too...
    NSLog(@"basemap query %@", self.portal.portalInfo.basemapGalleryGroupQuery);
    AGSPortalQueryParams *queryParams = [AGSPortalQueryParams queryParamsWithQuery:self.portal.portalInfo.basemapGalleryGroupQuery];
    [self.portal findGroupsWithQueryParams:queryParams];
}

-(void)portal:(AGSPortal*)portal operation:(NSOperation*)op didFindGroups:(AGSPortalQueryResultSet*)resultSet
{
    //found basemap group. Query for items in the basemap group
    AGSPortalGroup *basemapsGroup = (AGSPortalGroup *)[resultSet.results objectAtIndex:0];
    AGSPortalQueryParams *params = [AGSPortalQueryParams queryParamsForItemsOfType:AGSPortalItemTypeWebMap inGroup:basemapsGroup.groupId];
    [self.portal findItemsWithQueryParams:params];
}

-(void)portal:(AGSPortal*)portal operation:(NSOperation*)op didFindItems:(AGSPortalQueryResultSet*)resultSet
{
    //Filter out all of the Bing basemaps since this application doesn't have a key. If you have a Bing key, go
    //ahead and remove this code, and implement the AGSWebMapDelegate method to return your Bing App key
    NSMutableArray *onlineBasemapArray = [NSMutableArray arrayWithCapacity:6];
    for (AGSPortalItem *pi in resultSet.results)
    {
        if ([pi.title rangeOfString:@"Bing"].location == NSNotFound) {
            [onlineBasemapArray addObject:pi];
            
        }
    }
    
    //Create basemaps model object
//#warning Return the onlineBasemapArray to finish this implementation.
}




//Ensure some fields can't be seen in popup
- (void)filterPopupInfo:(AGSPopupInfo *)popupInfo
{
    NSArray *fieldInfos = popupInfo.fieldInfos;
    NSArray *fieldNamesToFilter = [NSArray arrayWithObjects:@"objectid", @"globalid", @"website", nil];
    
    for (AGSPopupFieldInfo *fi in fieldInfos) {
        if ([fieldNamesToFilter containsObject:fi.fieldName]) {
            fi.visible = NO;
        }
    }
}


- (void)handleDocumentOpenURL:(NSURL *)url
{
    return;
}

- (void)handleApplicationURL:(NSURL *)url
{
    return;
}

@end
