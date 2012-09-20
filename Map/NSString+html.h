//
//  NSString+html.h
//  ArcGISMobile
//
//  Created by Mark Dostal on 6/15/10.
//  Copyright 2010 ESRI. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (NSString_html)

//encode to html
-(NSString *) htmlEncode;

//decode from html - commonly used prior to decoding from JSON
-(NSString *) htmlDecode;
@end
