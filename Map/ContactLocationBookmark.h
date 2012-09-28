//
//  ContactLocation.h
//  Map
//
//  Created by Scott Sirowy on 10/14/11.
/*
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */
#import "LocationBookmark.h"
#import <AddressBook/AddressBook.h>

/*
 A type of location bookmark the includes the 
 contacts information
 */

@interface ContactLocationBookmark : LocationBookmark
{
    NSString *_detail;
    ABRecordRef _contactRef;
}

@property (nonatomic, copy) NSString *detail;
@property (nonatomic, assign) ABRecordRef contactRef;

-(BOOL)canMakeCall;
-(NSArray *)contactPhoneNumbers;

@end
