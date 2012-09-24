//
//  StopSignView.h
//  Map
//
//  Created by Scott Sirowy on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

/*
 Sign that shows a stop along a route
 */

#import "BlankSignView.h"
#import "ArcGIS+App.h"

@class Location;

@interface StopSignView : BlankSignView
{
    Location    *_location;
    
    UILabel     *_nameLabel;
    UIImageView *_imageView;
}

@property (nonatomic, strong) Location *location;

-(id)initWithFrame:(CGRect)frame withLocation:(Location *)location;

@end
