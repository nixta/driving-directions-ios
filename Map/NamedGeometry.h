//
//  NamedGeometry.h
//  Map
//
//  Created by Scott Sirowy on 9/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ArcGIS+App.h"
#import "TableViewDrawable.h"

@class AGSGeometry;
@class AGSEnvelope;

/*
 An object that subscribes to the 'TableViewDrawable' 
 protocol but that also has a geometry
 */

@protocol NamedGeometry <NSObject, TableViewDrawable>

@property (nonatomic, retain) AGSGeometry *geometry;

@optional

@property (nonatomic, retain) AGSEnvelope *envelope;

@end
