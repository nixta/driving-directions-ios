//
//  ContactLocation.m
//  Map
//
//  Created by Scott Sirowy on 10/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ContactLocationBookmark.h"

@implementation ContactLocationBookmark

@synthesize detail = _detail;
@synthesize contactRef = _contactRef;

-(void)dealloc
{
    self.detail = nil;
    
    [super dealloc];
}

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
    ABMultiValueRef phones =(NSString*)ABRecordCopyValue(self.contactRef, kABPersonPhoneProperty);
    BOOL canCall = (ABMultiValueGetCount(phones) > 0);
    CFRelease(phones);
    return canCall;
}

-(NSArray *)contactPhoneNumbers
{
    NSMutableArray *phoneNumbersArray = [NSMutableArray arrayWithCapacity:2];
    
    ABMultiValueRef phones =(NSString*)ABRecordCopyValue(self.contactRef, kABPersonPhoneProperty);
    for(CFIndex i = 0; i < ABMultiValueGetCount(phones); i++) {
        NSString *phone = (NSString *)ABMultiValueCopyValueAtIndex(phones, i);
        [phoneNumbersArray addObject:phone];
        [phone release];
    }
    
    CFRelease(phones);
    
    return phoneNumbersArray;
}

@end
