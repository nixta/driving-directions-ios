//
//  Organization.h
//  Map
//
//  Created by Scott Sirowy on 9/9/11.
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
#import <ArcGIS/ArcGIS.h>

@protocol OrganizationDelegate;

//#define kDefaultWebMapId @"15d033f017454856a0fb65f56b9c5a15"
#define kDefaultWebMapId @"5b84b12a666c477db2842bb5800d87c7"

@interface Organization : NSObject <AGSWebMapDelegate, AGSCoding>
{
    AGSWebMap                   *_webmap;
    BOOL                        _webmapLoaded;
    UIImage                     *_icon;
    AGSEnvelope                 *_defaultEnvelope;
    
    NSString                    *_basemapGalleryGroupQuery;
    NSString                    *_name;
    NSString                    *_portalName;
    NSString                    *_locatorUrlString;
    
    id<OrganizationDelegate>    __unsafe_unretained _delegate;
    AGSJSONRequestOperation     *_orgOperation;
}

@property (nonatomic, strong) AGSWebMap                 *webmap;
@property (nonatomic, readonly) BOOL                    webmapLoaded;
@property (nonatomic, strong) UIImage                   *icon;
@property (nonatomic, strong) AGSEnvelope               *defaultEnvelope;

@property (nonatomic, copy) NSString                    *name;
@property (nonatomic, copy) NSString                    *locatorUrlString;
@property (nonatomic, copy) NSString                    *basemapGalleryGroupQuery;
@property (nonatomic, copy) NSString                    *portalName;

@property (nonatomic, unsafe_unretained) id<OrganizationDelegate>  delegate;

-(void)retrieveOrganizationWebmap;
-(NSURL *)routeUrl;

@end


@protocol OrganizationDelegate <NSObject>

@optional
-(void)organization:(Organization *)org didDownloadWebmap:(AGSWebMap *)webmap;
-(void)organizationDidFailToDownloadWebmap:(Organization *)organization;

@end



