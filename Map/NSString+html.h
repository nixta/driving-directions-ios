//
//  NSString+html.h
//  ArcGISMobile
//
//  Created by Mark Dostal on 6/15/10.
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


@interface NSString (NSString_html)

//encode to html
-(NSString *) htmlEncode;

//decode from html - commonly used prior to decoding from JSON
-(NSString *) htmlDecode;
@end
