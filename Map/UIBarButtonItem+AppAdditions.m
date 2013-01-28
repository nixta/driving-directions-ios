/*
 Copyright © 2013 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

#import "UIBarButtonItem+AppAdditions.h"

@implementation UIBarButtonItem (AppAdditions)

//returns a rought width of all UIBarButtonItems... Not perfect, but
//better than having random code all over the place
+(CGFloat)width
{
    return 40;
}

@end
