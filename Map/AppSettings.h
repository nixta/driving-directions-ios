//
//  AppSettings.h
//  Map
//
//  Created by Scott Sirowy on 9/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

@class ArcGISOnlineConnection;

@interface AppSettings : NSObject <AGSCoding>
{
    ArcGISOnlineConnection  *_arcGISOnlineConnection;
}

@property (nonatomic, strong) ArcGISOnlineConnection    *arcGISOnlineConnection;

@end
