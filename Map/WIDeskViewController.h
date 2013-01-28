/*
 Copyright © 2013 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>


/*
 Main View Controller. Houses all relevant views for the application, including the map, 
 the layered views for contacts, list of stops,etc., basemaps
 */

@interface WIDeskViewController : UIViewController <AGSPortalDelegate,AGSWebMapDelegate>

@property (nonatomic,strong) AGSPortal *portal;
@property (nonatomic,strong) AGSWebMap *webMap;

/* Method to handle opening a file from another appplication */
- (void)handleDocumentOpenURL:(NSURL *)url;

/* Method to handle when a URL is hit that we can handle with our app
 i.e inspectiondemo://featureLayer-objectid
 */
- (void)handleApplicationURL:(NSURL *)url;

@end
