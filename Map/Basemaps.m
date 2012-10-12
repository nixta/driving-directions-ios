/*
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

#import "Basemaps.h"
#import "AppSettings.h"
#import "ContentItem.h"
#import "ArcGISOnlineServices.h"
#import "ArcGISOnlineConnection.h"
#import "ArcGISAppDelegate.h"
#import "ArcGISMobileConfig.h"

#import "MapAppSettings.h"
#import "Organization.h"

//anonymous helper methods
@interface Basemaps ()

-(void)getESRIGroupID;
-(void)getBaseMaps;
-(BasemapInfo *)defaultBasemap;
-(void)finishWithSuccess:(BOOL)success;

@property (nonatomic, unsafe_unretained) ArcGISAppDelegate         *app;
@property (nonatomic, strong) SearchResponse            *searchResponse;

/*Collection of basemap items */
@property (nonatomic, strong) NSMutableArray            *basemapInfos;

/*ESRI group ID for basemaps group */
@property (nonatomic, strong) NSString                  *groupID;

@property (nonatomic, strong) AGSJSONRequestOperation   *esriGroupIdOp;
@property (nonatomic, strong) AGSJSONRequestOperation   *baseMapsOp;

@end

@implementation Basemaps


#pragma mark -
#pragma mark Public Interface

//default initializer
-(id)initWithDelegate:(id<BasemapDelegate>)aDelegate
{
    if(self = [super init])
    {
        self.delegate = aDelegate;
    }
    
    return self;
}

//Begin process of downloading basemaps. The object who begins this process
//should have set a delegate so as to know when the basemap process is finished
-(void)startDownload
{
    _isDownloading = YES;
    _finishedDownloading = NO;
    
    //kicks of process. Everything is else is handled in sequence
    [self getESRIGroupID];
}

-(NSInteger)numberOfBasemaps
{
    return self.basemapInfos.count;
}

-(BasemapInfo *)basemapAtIndex:(NSUInteger)index
{
    if (index >= self.basemapInfos.count || self.isDownloading) {
        return nil;
    }
    
    return [self.basemapInfos objectAtIndex:index];
}

#pragma mark -
#pragma mark Lazy Loads
-(NSMutableArray *)basemapInfos
{
	if (_basemapInfos == nil)
    {
        NSMutableArray* newArray = [[NSMutableArray alloc] init];
        self.basemapInfos = newArray;
    }
	
	return _basemapInfos;
}

-(ArcGISAppDelegate *)app
{
    if(_app == nil)
    {
        self.app = [[UIApplication sharedApplication] delegate];
    }
    
    return _app;
}


#pragma mark -
#pragma mark Request Methods for grabbing Basemaps
//
// Getting the list of base maps needs to be done in two parts:
// First, search for the _app.config.basemapsGroupQueries group.  Then, use the
// ESRI self.groupId to search for content related to that ID.  The result of that
// search is the list of base maps.
//
// This method, getESRIGroupID, kicks off that chain of events which is continued
// in getBaseMaps.
//
- (void) getESRIGroupID
{	
    NSString *queryString = @"title:\"ArcGIS Online Basemaps\" AND owner:esri";  //mas.organization.basemapGalleryGroupQuery;
    
    NSString* urlString = [NSString stringWithFormat:@"community/groups?q=%@&f=json", queryString];
    
    _app.appSettings = self.app.appSettings;
    ArcGISOnlineConnection *connection = _app.appSettings.arcGISOnlineConnection;
	
    //NSLog(@"connection url: %@", urlString);
    
	//create the url request, complete with token and referer, if signed in
	NSURLRequest *contentReq = [connection requestForUrlString:urlString withHost:nil];
    
    self.esriGroupIdOp = [[AGSJSONRequestOperation alloc] initWithRequest:contentReq];
    self.esriGroupIdOp.target = self;
    self.esriGroupIdOp.action = @selector(esriBaseMapsGroupOperation:didSucceed:);
    self.esriGroupIdOp.errorAction = @selector(esriBaseMapsGroupOperation:didFailWithError:);
    [[AGSRequestOperation sharedOperationQueue] addOperation:self.esriGroupIdOp];
}

- (void)esriBaseMapsGroupOperation:(AGSJSONRequestOperation*)op didSucceed:(NSDictionary*)json {
    SearchResponse* searchResults = [[SearchResponse alloc] initWithJSON:json];
    self.searchResponse = searchResults;
	
	//results from connecting to the group ESRI
    NSArray *items = [AGSJSONUtility decodeFromDictionary:json withKey:@"results" fromClass:[Group class]];
    
    //make sure we actually hit proper group
    if ([items count] == 1)
    {      
        Group *esriGroup = (Group *)[items objectAtIndex:0];
        self.groupID = esriGroup.groupId;
        [self getBaseMaps];
    }
    //didn't find ESRI basemaps group, so just add default base map
    else {
        
        //automatically add the default base map to list of items
        [self.basemapInfos addObject:[self defaultBasemap]];
        
        //basemap download didn't work out so well this time, but still have
        //one basemap (the default one) to show
        [self finishWithSuccess:YES];
    }
    
    // nil out so result data released
    self.esriGroupIdOp = nil;
}

- (void)esriBaseMapsGroupOperation:(AGSJSONRequestOperation*)op didFailWithError:(NSError*)error {
    [self finishWithSuccess:NO];
    
    // nil out so result data released
    self.esriGroupIdOp = nil;
}

//Search on ArcGIS online after we have retrieved ESRIs groupID. Method creates a search string with groupID embedded
- (void) getBaseMaps
{
	
    // This could be done using the WIDeskViewController that return the items instead of the urls
	NSString *urlString = 
	[NSString stringWithFormat:@"search?q=group:%@ AND type:'web map'&sortField=name&sortOrder=desc&num=50&f=json", _groupID];
    
    ArcGISOnlineConnection *connection = self.app.appSettings.arcGISOnlineConnection;
    
	//create the url request, complete with token and referer, if signed in
	NSURLRequest *contentReq = [connection requestForUrlString:urlString withHost:nil];
    
    self.baseMapsOp = [[AGSJSONRequestOperation alloc] initWithRequest:contentReq];
    self.baseMapsOp.target = self;
    self.baseMapsOp.action = @selector(baseMapsItemsOperation:didSucceed:);
    self.baseMapsOp.errorAction = @selector(baseMapsItemsOperation:didFailWithError:);
    [[AGSRequestOperation sharedOperationQueue] addOperation:self.baseMapsOp];
}

-(void)baseMapsItemsOperation:(NSOperation*)jrop didFailWithError:(NSError*)error {
    [self finishWithSuccess:NO];
    
    // nil out to release data
    self.baseMapsOp = nil;
}

-(void)baseMapsItemsOperation:(NSOperation*)jrop didSucceed:(NSDictionary*)json {
    //this is the connection which returned the list of related items
    NSArray *items = [AGSJSONUtility decodeFromDictionary:json withKey:@"results" fromClass:[ContentItem class]];
    
    //sort the items with most recent first (sort on 'uploaded' property and descending)
    NSMutableArray *sortedItems = [items mutableCopy];
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"uploaded" ascending:NO];
    [sortedItems sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];
    
    items = sortedItems;
    
    //automatically add the default base map to list of items
    [self.basemapInfos addObject:[self defaultBasemap]];
    
    //add the rest of the basemaps from the group to the list of items
    for (ContentItem* item in items)
    {
        if ([item.type caseInsensitiveCompare:@"Web Map"] == NSOrderedSame)
        {
            NSString *agolLoc = [ArcGISOnlineConnection portalSharingLocation];
            NSString *urlString = [NSString stringWithFormat:@"%@/content/items/%@/data", agolLoc, item.itemId];
            
            NSLog(@"BaseMap title %@", item.title);            
           
            // If the basemap isn't bing
            if ( [self foundSubstring:item.title find:@"Bing"] == NO) {            
                BasemapInfo *basemapInfo = [[BasemapInfo alloc] initWithTitle:item.title urlString:urlString contentItem:item];
                [self.basemapInfos addObject:basemapInfo];
            }
        }
    }
    
    //"Great success!" - Borat
    [self finishWithSuccess:YES];
    
    // nil out to release data
    self.baseMapsOp = nil;
}

-(BOOL) foundSubstring:(NSString*)originalString find:(NSString*)toFind
{
    
    NSRange isRange = [originalString rangeOfString:toFind options:NSCaseInsensitiveSearch];
    if(isRange.location == 0) {
        return YES;
    }

    return NO;
}

#pragma mark -
#pragma mark Utility Methods

-(BasemapInfo *)defaultBasemap
{
    BasemapInfo *defaultBasemap =  [[BasemapInfo alloc] initWithTitle:NSLocalizedString(@"Default Basemap", nil) 
                                                             urlString:nil 
                                                           contentItem:nil];
    
    defaultBasemap.isDefaultBasemap = YES;
    return defaultBasemap;
}

//Informs delegate that download process is done.
-(void)finishWithSuccess:(BOOL)success
{
    //update status
    _isDownloading = NO;
    _finishedDownloading = YES;
    
    //call the right selector depending on the success/failure of download
    SEL delegateSelector = success ? @selector(basemapsFinishedDownloading) : @selector(basemapsFailedDownloading);
    
    if([self.delegate respondsToSelector:delegateSelector])
    {
        [self.delegate performSelector:delegateSelector];
    }
}

#pragma mark -
#pragma mark Memory Management
- (void)dealloc {
    
    
    [self.esriGroupIdOp cancel];
    
    [self.baseMapsOp cancel];
    
}

@end


@interface BasemapInfo () 

@property (nonatomic, strong, readwrite) ContentItem *contentItem;
@property (nonatomic, strong, readwrite) NSString *title;
@property (nonatomic, strong, readwrite) NSString *urlString;

@end

@implementation BasemapInfo

-(id)initWithTitle:(NSString *)title urlString:(NSString *)urlString contentItem:(ContentItem *)contentItem
{
    self = [super init];
    if(self)
    {
        self.title = title;
        self.urlString = urlString;
        self.contentItem = contentItem;
        
        self.isDefaultBasemap = NO;
    }
    
    return self;
}

- (NSString *)mapThumbnailURLString
{
    if (self.contentItem == nil)
        return nil;
    
    return [NSString stringWithFormat:@"content/items/%@/info/%@",self.contentItem.itemId, self.contentItem.thumbnail];
}

@end


