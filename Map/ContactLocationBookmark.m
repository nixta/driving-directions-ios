//
//  ContactLocation.m
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

#import "ContactLocationBookmark.h"

@implementation ContactLocationBookmark

@synthesize detail = _detail;
@synthesize contactRef = _contactRef;


//Since a contact uses the detail for his address, use that to search
-(NSString *)searchString
{
    if (self.detail != nil && self.detail.length > 0) {
        return self.detail;
    }
    
    return [super searchString];
}

-(BOOL)canMakeCall
{
    ABMultiValueRef phones =(__bridge ABMultiValueRef)((NSString*)CFBridgingRelease(ABRecordCopyValue(self.contactRef, kABPersonPhoneProperty)));
    BOOL canCall = (ABMultiValueGetCount(phones) > 0);
    CFRelease(phones);
    return canCall;
}

-(NSArray *)contactPhoneNumbers
{
    NSMutableArray *phoneNumbersArray = [NSMutableArray arrayWithCapacity:2];
    
    ABMultiValueRef phones =(__bridge ABMultiValueRef)((NSString*)CFBridgingRelease(ABRecordCopyValue(self.contactRef, kABPersonPhoneProperty)));
    for(CFIndex i = 0; i < ABMultiValueGetCount(phones); i++) {
        NSString *phone = (NSString *)CFBridgingRelease(ABMultiValueCopyValueAtIndex(phones, i));
        [phoneNumbersArray addObject:phone];
    }
    
    CFRelease(phones);
    
    return phoneNumbersArray;
}

@end
