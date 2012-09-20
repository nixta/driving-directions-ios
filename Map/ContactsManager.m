/*
 ContactsManager.m
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

#import "ContactsManager.h"

//C pointer reference to self so C callback can get back into an Objective-C
//method
void *callbackSelf;

//AddressBook C function callback prototype
void somethingChangedInAddressBook ( ABAddressBookRef addressBook, CFDictionaryRef info, void *context);

@interface ContactsManager ()

-(void)initializeAddressBook;
-(void)clearAddressBook;

//int contactsSort( id obj1, id obj2, void *context);

@end


//AddressBook C function callback
void somethingChangedInAddressBook (
                                    ABAddressBookRef addressBook,
                                    CFDictionaryRef info,
                                    void *context
                                    )
{
    //call back into Objective-C method
    [(id)callbackSelf clearAddressBook];
}


@implementation ContactsManager

@synthesize allContacts = _allContacts;
@synthesize allContactsWithAddresses = _allContactsWithAddresses;


//class method that returns a singleton object for 
//working with a device's contact list
//This method should be called instead of 
//trying to alloc init a user-defined instance
+(ContactsManager *)sharedContactsManager
{
    static ContactsManager *instance;
    @synchronized(self)
    {
        if(!instance)
        {
            instance = [[ContactsManager alloc] init];
            [instance initializeAddressBook];
            callbackSelf = instance;
        }
    }
    
    return instance;
}

//initialize member variable with the AddressBook
-(void)initializeAddressBook
{
    //wrapped in a synchronization mechanism just in case
    //singleton is hit in a multi-threaded environment
    @synchronized(self)
    {
        _addressBook = ABAddressBookCreate();
        
        //register object as the callback when something in the address book changes
        //from an external program, or another thread
        ABAddressBookRegisterExternalChangeCallback(
                                                    _addressBook,                   //addressBook in question
                                                    somethingChangedInAddressBook,  //callback method when something changes
                                                    self);                          //object to pass into callback, in this case need a referenc to self
    }
}

-(void)clearAddressBook
{
    @synchronized(self)
    {
        self.allContacts = nil;
        self.allContactsWithAddresses = nil;
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:@"AddressBookContactChange" object:nil];
    }
}

//returns all contacts in user's address book
-(NSArray *)allContacts
{
    //wrapped in a synchronization mechanism just in case
    //singleton is hit in a multi-threaded environment
    @synchronized(self)
    {
        if(!_allContacts)
        {
            ABRecordRef source = ABAddressBookCopyDefaultSource(_addressBook);
            ABPersonSortOrdering ordering = ABPersonGetSortOrdering();
            NSArray *contacts = (NSArray*)ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(_addressBook, source, ordering);
            self.allContacts = contacts;
            
            CFRelease(source);
            [contacts release];
        }
    }
    
    return _allContacts;
}

//returns all contacts in address book with addresses
-(NSArray *)allContactsWithAddresses
{
    //wrapped in a synchronization mechanism just in case
    //singleton is hit in a multi-threaded environment
    @synchronized(self)
    {
        if(!_allContactsWithAddresses)
        {
            NSMutableArray *contactsWithAddresses = [NSMutableArray arrayWithCapacity:10];
            
            int numContacts = self.allContacts.count;        
            for (int i = 0; i < numContacts; i++) {
                //grab the person record from list of contacts
                ABRecordRef person = [self.allContacts objectAtIndex:i];
                                
                //check to see if person has at least one address. If so, add to list
                ABMutableMultiValueRef addressMulti = ABRecordCopyValue(person, kABPersonAddressProperty);
                
                if (ABMultiValueGetCount(addressMulti) > 0) {
                    [contactsWithAddresses addObject:(id)person];
                }
                
                CFRelease(addressMulti);
            } 
            self.allContactsWithAddresses = contactsWithAddresses;
        }
    }
    
    return _allContactsWithAddresses;    
}

/*
// helper function to sort feature layers by their name property, a->z
int contactsSort( id obj1, id obj2, void *context) {
    
    ABRecordRef record1 = obj1;
    ABRecordRef record2 = obj2;
    
    NSString *firstName1 = (NSString *)ABRecordCopyValue(record1, kABPersonFirstNameProperty);
    NSString *lastName1 = (NSString *)ABRecordCopyValue(record1, kABPersonLastNameProperty);
    NSString *fullName1 = [NSString stringWithFormat:@"%@%@", firstName1, lastName1];
    [firstName1 release];
    [lastName1 release];
    
    NSString *firstName2 = (NSString *)ABRecordCopyValue(record2, kABPersonFirstNameProperty);
    NSString *lastName2 = (NSString *)ABRecordCopyValue(record2, kABPersonLastNameProperty);
    NSString *fullName2 = [NSString stringWithFormat:@"%@%@", firstName2, lastName2];
    [firstName2 release];
    [lastName2 release];
    
	
	return [fullName1 compare:fullName2];
}  */

//make sure copying can't take place
- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

//don't alter retain count
- (id)retain
{
    return self;
}

/*
//make sure user can't release sharedContacts
- (void)release
{
    // do nothing
}  */

//autorelease shouldn't do anything
- (id)autorelease
{
    return self;
}

//just a protection mechanism from contacts from ever being deallocated
- (NSUInteger)retainCount
{
    return NSUIntegerMax; // Random high number!
}

@end
