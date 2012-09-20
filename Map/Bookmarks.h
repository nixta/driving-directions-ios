//
//  Bookmarks.h
//  Map
//
//  Created by Scott Sirowy on 10/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DrawableList.h"
#import "ArcGIS+App.h"

@class Location;

@interface Bookmarks : DrawableList <AGSCoding>
{
}

-(void)addBookmark:(Location *)bookmark;

@end


