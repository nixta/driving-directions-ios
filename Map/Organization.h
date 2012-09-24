//
//  Organization.h
//  Map
//
//  Created by Scott Sirowy on 9/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ArcGIS+App.h"

@protocol OrganizationDelegate;

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


//For Testing Purposes
@interface SanFranciscoOrganization : Organization 
@end

//For testing purposes
@interface PoliceOrganization : Organization 
@end

//For Testing Purposes
@interface ATTOrganization : Organization 
@end

//For Testing Purposes
@interface TeapotOrganization : Organization 
@end

