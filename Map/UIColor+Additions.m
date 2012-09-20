//
//  UIColor+Additions.m
//  ArcGISMobile
//
//  Created by ryan3374 on 11/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UIColor+Additions.h"


@implementation UIColor (Additions)

/*
 Returns the scrollViewTexturedBackgroundColor if available, otherwise returns a similar color.
 */
+(UIColor*)darkBackgroundColor{
	if ([UIColor respondsToSelector:@selector(scrollViewTexturedBackgroundColor)]){
		return [UIColor scrollViewTexturedBackgroundColor];
	}
	else{
		return [UIColor colorWithRed:.365 green:.376 blue:.380 alpha:1];
	}
}

/*
 Light grayish-white color used all over the app
 */
+(UIColor*)offWhiteColor
{
    return [UIColor colorWithRed:245.0f/255.0f green:245.0f/255.0f blue:245.0f/255.0f alpha:1.0f];
}

@end
