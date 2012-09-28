//
//  ContactsList.m
//  Map
//
//  Created by Scott Sirowy on 10/24/11.
/*
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */
#import "ContactsList.h"
#import "ContactLocationBookmark.h"
#import "Location.h"
#import <AddressBookUI/AddressBookUI.h>

@interface DrawableList () 

@property (nonatomic, retain, readwrite) NSMutableArray *items;

@end

@interface ContactsList () 

@property (nonatomic, strong, readwrite) NSArray            *sectionTitles;
@property (nonatomic, strong, readwrite) NSMutableArray     *sections;

-(NSString *)sectionTitleForRecord:(ABRecordRef)record;

@end

@implementation ContactsList

@synthesize sectionTitles = _sectionTitles;
@synthesize sections = _sections;


-(id)initWithName:(NSString *)name withItems:(NSMutableArray *)items
{
    self = [super initWithName:name withItems:items];
    if(self)
    {
        if (self.items && self.items.count > 0) {
            self.sections = [NSMutableArray arrayWithCapacity:3];
            NSMutableArray *sectionTitles = [NSMutableArray arrayWithCapacity:3];
            
            ContactLocationBookmark *cl = (ContactLocationBookmark *)[self.items objectAtIndex:0];
            
            NSString *sectionTitle = [self sectionTitleForRecord:cl.contactRef];
            NSMutableArray *newSection = [NSMutableArray arrayWithCapacity:2];
            [newSection addObject:cl];
            
            for(int i = 1; i < self.items.count; i++)
            {
                ContactLocationBookmark *cl = (ContactLocationBookmark *)[self.items objectAtIndex:i];
                
                if ([[self sectionTitleForRecord:cl.contactRef] isEqualToString:sectionTitle]) {
                    [newSection addObject:cl];
                }
                //new section...
                else
                {
                    //add old to storage
                    [self.sections addObject:newSection];
                    [sectionTitles addObject:sectionTitle];
                    
                    //create new section title and array
                    sectionTitle = [self sectionTitleForRecord:cl.contactRef];
                    newSection = [NSMutableArray arrayWithCapacity:2];
                    [newSection addObject:cl];
                }
            }
            
            //add last to storage
            [self.sections addObject:newSection];
            [sectionTitles addObject:sectionTitle];
            
            self.sectionTitles = sectionTitles;
        }
    }
    
    return self;
}

-(NSString *)sectionTitleForRecord:(ABRecordRef)record
{
    NSString *firstName = (NSString *)CFBridgingRelease(ABRecordCopyValue(record, kABPersonFirstNameProperty));
    if (!firstName) {
        firstName = @"";
    }
    
    NSString *lastName = (NSString *)CFBridgingRelease(ABRecordCopyValue(record, kABPersonLastNameProperty));
    if(!lastName)
    {
        lastName = @"";
    }
    
    NSString *sectionTitle = (ABPersonGetSortOrdering() == kABPersonSortByFirstName) ? firstName : lastName;
    
    if (sectionTitle.length > 1) {
        sectionTitle = [[sectionTitle substringToIndex:1] uppercaseString];
    }
    else
    {
        sectionTitle = [sectionTitle uppercaseString];
    }
    
    return sectionTitle;
}

-(NSUInteger)numberOfResultTypes
{
    return self.sectionTitles.count;
}

-(NSUInteger)numberOfResultsInSection:(NSUInteger)section
{
    NSArray *currentSection = [self.sections objectAtIndex:section];
    return currentSection.count;
}

-(NSString *)titleOfResultTypeForSection:(NSUInteger)section
{
    return [self.sectionTitles objectAtIndex:section];
}

-(id<TableViewDrawable>)resultForRowAtIndexPath:(NSIndexPath *)index
{
    NSArray *currentSection = [self.sections objectAtIndex:index.section];
    return [currentSection objectAtIndex:index.row];
}

@end
