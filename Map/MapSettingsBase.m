//
//  MapSettings.m
//  ArcGISMobile
//
//  Created by Scott Sirowy on 12/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MapSettingsBase.h"
#import "ContentItem.h"
#import "ArcGISOnlineConnection.h"
#import "NSString+html.h"
#import "NSDictionary+Additions.h"
#import "ArcGIS+App.h"
#import "AppSettings.h"


static NSString* _referer = @"www.esri.com/arcgismobile";

@interface MapSettingsBase ()

-(ContentItem*)downloadContentItem;
-(NSDictionary *)getDataFromUrl:(NSString *)sUrl;

@end


@implementation MapSettingsBase

@synthesize title = _title;
@synthesize url =_url;
@synthesize mapIcon = _mapIcon;
@synthesize mapIconName = _mapIconName;

@synthesize contentItem = _contentItem;
@synthesize webmap = _webmap;


-(id)init{
	if (self = [super init]){
	}
	return self;
}

-(id) initWithUrl:(NSString *)sUrl
{
    if (self = [super init])
    {
        self.url = sUrl;
        
        //downloadContentItem only needs URL to download the content item
        ContentItem* contentItem = [self downloadContentItem];
        
		self.title = contentItem.title;
		self.url = sUrl;
		self.contentItem = contentItem;
		self.webmap = nil;
    }
    
    return self;
}

-(id)initWithName:(NSString *)n
			  url: (NSString *)u
	  contentItem: (ContentItem *)c
{
	if (self = [super init])
	{
		self.title = n;
		self.url = u;
		self.contentItem = c;
		self.webmap = nil;
	}
	return self;
}

#pragma mark -
#pragma mark AGSCoding

- (void)decodeWithJSON:(NSDictionary *)json {
	self.title = [JSONUtility getStringFromDictionary:json withKey:@"title"];
	self.url = [JSONUtility getStringFromDictionary:json withKey:@"url"];
	self.contentItem = [[[ContentItem alloc]initWithJSON:[json valueForKey:@"contentItem"]]autorelease];
    self.mapIconName = [json objectForKey:@"mapIconName"];
}

- (id)initWithJSON:(NSDictionary *)json {
    if (self = [super init]) {
        [self decodeWithJSON:json];
    }
    return self;
}

- (NSDictionary *)encodeToJSON;
{
	NSMutableDictionary *json = [NSMutableDictionary dictionaryWithCapacity:1];
	
    if (!self.title)
    {
        self.title = @"";
    }
    
	[json setObject:self.title forKey:@"title"];
	[json setObject:self.url forKey:@"url"];
	[NSDictionary safeSetObjectInDictionary:json object:[self.contentItem encodeToJSON] withKey:@"contentItem"];

	[NSDictionary safeSetObjectInDictionary:json object:self.mapIconName withKey:@"mapIconName"];
	
	return json;
}

#pragma mark _

-(AGSWebMap *)downloadMobileWebMap {	
	
    NSDictionary *json = [self getDataFromUrl:self.url];
    
	if (json == nil){
		return nil;
	}
	
	AGSWebMap *config = [[[AGSWebMap alloc]initWithJSON:json]autorelease];
	return config;
}

-(ContentItem*)downloadContentItem
{
    //remove trailing '/data' in order to get content item and replace with "?f=json"
  	NSString *urlString = [self.url stringByReplacingOccurrencesOfString:@"/data" withString:@"?f=json"];
    
    NSDictionary *json = [self getDataFromUrl:urlString];
    
	ContentItem *contentItem = [[[ContentItem alloc]initWithJSON:json]autorelease];
	return contentItem;
}

-(NSDictionary *)getDataFromUrl:(NSString *)sUrl
{
    NSString *urlString = [sUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	urlString = [urlString stringByReplacingOccurrencesOfString:@"'" withString:@"%22"];
    
    //append token, if necessary
    ArcGISAppDelegate *_app = (ArcGISAppDelegate *)[UIApplication sharedApplication].delegate;
    ArcGISOnlineConnection *connection = _app.appSettings.arcGISOnlineConnection;
    
    NSURLRequest *request = nil;
    if ([connection isSignedIn])
    {
        //check to see if we have an '?' in the url...
        //if we do, then to separator needs to be a "&";
        //if not, then the separator needs to be a "?"
        NSString *separator = @"&";
        NSRange range = [urlString rangeOfString:@"?"];
        if (range.location == NSNotFound)
            separator = @"?";
        
        NSString *secureURL = [NSString stringWithFormat:@"%@%@token=%@",
                               urlString,
                               separator,
                               connection.token];
        
        NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:[[NSURL URLWithString:secureURL] standardizedURL]];
        [req setValue:_referer forHTTPHeaderField:@"Referer"];
        request = req;        
    }
    else {
        NSURLRequest *req = [[NSURLRequest alloc] initWithURL: [[NSURL URLWithString:urlString] standardizedURL]];
        request = req;        
    }
    
	NSError *err = nil;
    NSURLResponse *response = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    [request release];
    
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	
    NSDictionary *json = [responseString JSONValue];
    [responseString release];
    
    return json;
}

-(AGSWebMap *) webmap{
	if (_webmap == nil){
		self.webmap = [self downloadMobileWebMap];
	}
	return _webmap;
}

-(BOOL)isPublic
{
    return ([self.contentItem.access isEqualToString:@"public"]);
}

#pragma mark _

- (NSString *)mapThumbnailURLString
{
    return [NSString stringWithFormat:@"content/items/%@/info/%@",
            self.contentItem.itemId,
            self.contentItem.thumbnail];
    
    //    return [NSString stringWithFormat:@"%@/../info/%@", self.url, self.contentItem.thumbnail];
}

- (void)setMapIconName:(NSString *)iconName
{
    if (iconName && (id)iconName != [NSNull null] && [iconName length] > 0)
    {
        [_mapIconName release];
        _mapIconName = [iconName copy];
        
        self.mapIcon = [UIImage imageNamed:iconName];
    }
}

#pragma mark _
#pragma mark dealloc

-(void)dealloc
{
	self.title = nil;
	self.url = nil;
	self.contentItem = nil;	
	self.webmap = nil;
    self.mapIcon = nil;
    self.mapIconName = nil;
    
	[super dealloc];
}


@end
