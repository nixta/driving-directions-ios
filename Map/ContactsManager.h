/*
ContactsManager.h
ArcGISMobile
COPYRIGHT 2011 ESRI

TRADE SECRETS: ESRI PROPRIETARY AND CONFIDENTIAL
Unpublished material - all rights reserved under the
Copyright Laws of the United States and applicable international
laws, treaties, and conventions.

For additional information, contact:
Environmental Systems Research Institute, Inc.
Attn: Contracts and Legal Services Department
380 New York Street
Redlands, California, 92373
USA

email: contracts@esri.com
*/

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import "DrawableContainerDelegate.h"

//class that gives access to list of contacts.

@interface ContactsManager : NSObject
{
    ABAddressBookRef    _addressBook;
    NSArray             *_allContacts;
    NSArray             *_allContactsWithAddresses;
}

@property (nonatomic, strong) NSArray *allContacts;
@property (nonatomic, strong) NSArray *allContactsWithAddresses;

//class method that returns a singleton object for 
//working with a device's contact list
+(ContactsManager *)sharedContactsManager;

@end
