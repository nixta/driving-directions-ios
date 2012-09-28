//
//  ContactsManager+ContactsManager_DrawableList.m
//  Map
//
//  Created by Scott Sirowy on 10/12/11.
/*
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

#import "ContactsManager+ContactsManager_DrawableList.h"
#import "ContactsList.h"
#import "ContactLocationBookmark.h"
#import "ArcGISMobileConfig.h"
#import "ArcGISAppDelegate.h"

@implementation ContactsManager (ContactsManager_DrawableList)

+(NSString *)nameForRecord:(ABRecordRef)record
{
    ABPersonCompositeNameFormat nameFormat = ABPersonGetCompositeNameFormat();
    
    NSString *firstName = (NSString *)CFBridgingRelease(ABRecordCopyValue(record, kABPersonFirstNameProperty));
    if (!firstName) {
        firstName = @"";
    }
    
    NSString *lastName = (NSString *)CFBridgingRelease(ABRecordCopyValue(record, kABPersonLastNameProperty));
    if(!lastName)
    {
        lastName = @"";
    }
    
    NSString *firstString = (nameFormat == kABPersonCompositeNameFormatFirstNameFirst) ? firstName : lastName;
    NSString *lastString = (nameFormat == kABPersonCompositeNameFormatLastNameFirst) ? firstName : lastName;
    
    return [NSString stringWithFormat:@"%@ %@", firstString, lastString];
    
}

+(NSString *)stringForAddress:(NSDictionary *)address
{
    NSString *addressText = [NSString string];
    
    //assembly string from candidate address dictionary
    NSString *streetField = [address objectForKey:(NSString *)kABPersonAddressStreetKey];
    NSString *cityField = [address objectForKey:(NSString *)kABPersonAddressCityKey];
    NSString *stateField = [address objectForKey:(NSString *)kABPersonAddressStateKey];
    NSString *zipField = [address objectForKey:(NSString *)kABPersonAddressZIPKey];
    NSString *countryField = [address objectForKey:(NSString *)kABPersonAddressCountryKey];
    
    
    BOOL bAddComma = NO;
    BOOL bAddSpace = NO;
    
    if (streetField != nil)
    {
        addressText = [addressText stringByAppendingFormat:@"%@", streetField];
        bAddComma = YES;
    }
    if (cityField != nil)
    {
        addressText = [addressText stringByAppendingFormat:@"%@%@", (bAddComma ? @", " : @""), cityField];
        bAddComma = YES;
    }
    if (stateField != nil)
    {
        addressText = [addressText stringByAppendingFormat:@"%@%@", (bAddComma ? @", " : @""), stateField];
        bAddSpace = YES;
    }
    if (zipField != nil)
    {
        //no comma, just a space between state and Zip
        addressText = [addressText stringByAppendingFormat:@"%@%@", (bAddSpace ? @" " : @""), zipField];
        bAddSpace = YES;
    }            
    if (countryField != nil)
    {
        //no comma, just a space between state and Zip
        addressText = [addressText stringByAppendingFormat:@"%@%@", (bAddSpace ? @" " : @""), countryField];
    }           
    
    return addressText;
}

-(ContactsList *)drawableContactsList
{
    NSArray *contacts = [[ContactsManager sharedContactsManager] allContactsWithAddresses];
    
    ArcGISAppDelegate *app = [[UIApplication sharedApplication] delegate];
    NSURL *locatorUrl = [NSURL URLWithString:app.config.locatorServiceUrl];
    
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:contacts.count];
    
    for(int i = 0; i < contacts.count; i++)
    {
        ABRecordRef record = (__bridge ABRecordRef)([contacts objectAtIndex:i]);
        
        //grab all addresses
        ABMutableMultiValueRef addressMulti = ABRecordCopyValue(record, kABPersonAddressProperty);
        NSMutableArray *addressArray = [NSMutableArray arrayWithCapacity:2];
        int nMultiValues = ABMultiValueGetCount(addressMulti);
        
        for (int i = 0; i < nMultiValues; i++)
        {
            NSDictionary *anAddress = (NSDictionary *)CFBridgingRelease(ABMultiValueCopyValueAtIndex(addressMulti, i));
            [addressArray addObject:anAddress];
            
            ContactLocationBookmark *contact= [[ContactLocationBookmark alloc] initWithName:[ContactsManager nameForRecord:record] 
                                                                     anIcon:[UIImage imageNamed:@"ContactPin.png"]
                                                                 locatorURL:locatorUrl];
            
            contact.detail = [ContactsManager stringForAddress:anAddress];
            contact.contactRef = record;
            
            [items addObject:contact];
        }
        
        CFRelease(addressMulti);
    }
    
    ContactsList *contactsList = [[ContactsList alloc] initWithName:NSLocalizedString(@"Contacts", nil) 
                                                          withItems:items];

    
    return contactsList;
}

@end
