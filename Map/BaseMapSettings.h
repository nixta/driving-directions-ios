//
//  BaseMapSettings.h
//  ArcGISMobile
//
//  Created by Scott Sirowy on 12/22/10.
//  Copyright 2010 ESRI. All rights reserved.
//
//Directly subclasses MapSettingsBase, and doesn't add anything
//new. Different class name merely for convenience of naming, and
//adding a concreteness to MapSettingsBase

#import <Foundation/Foundation.h>
#import "MapSettingsBase.h"


@interface BaseMapSettings : MapSettingsBase <AGSCoding> {

}

@end
