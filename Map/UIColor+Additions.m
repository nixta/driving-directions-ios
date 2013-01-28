/*
 Copyright © 2013 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

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
