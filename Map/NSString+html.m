//
//  NSString+html.m
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

#import "NSString+html.h"

@implementation NSString (NSString_html)

-(NSString *) htmlEncode {
    NSMutableString * temp = [self mutableCopy];
	
    [temp replaceOccurrencesOfString:@"&"
                          withString:@"&amp;"
                             options:0
                               range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"<"
                          withString:@"&lt;"
                             options:0
                               range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@">"
                          withString:@"&gt;"
                             options:0
                               range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"\""
                          withString:@"&quot;"
                             options:0
                               range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"'"
                          withString:@"&apos;"
                             options:0
                               range:NSMakeRange(0, [temp length])];
	
    return temp;
}

-(NSString *) htmlDecode {
    NSMutableString * temp = [self mutableCopy];
	
    [temp replaceOccurrencesOfString:@"&amp;"
                          withString:@"&"
                             options:0
                               range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&lt;"
                          withString:@"<"
                             options:0
                               range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&gt;"
                          withString:@">"
                             options:0
                               range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&quot;"
                          withString:@"\""
                             options:0
                               range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&apos;"
                          withString:@"'"
                             options:0
                               range:NSMakeRange(0, [temp length])];
	
    return temp;
}

@end
