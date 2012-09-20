//
//  ContactLocation.h
//  Map
//
//  Created by Scott Sirowy on 10/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

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
