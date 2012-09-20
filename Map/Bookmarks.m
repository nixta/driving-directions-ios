//
//  Bookmarks.m
//  Map
//
//  Created by Scott Sirowy on 10/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Bookmarks.h"
#import "DrawableList.h"
#import "ContactsManager.h"
#import "NamedGeometry.h"
#import "Location.h"
#import "LocationBookmark.h"

@interface DrawableList () 

@property (nonatomic, retain, readwrite) NSMutableArray  *items;

@end

@implementation Bookmarks

#pragma mark -
#pragma mark Default Initializer
-(id)init
{
    return [super initWithName:NSLocalizedString(@"My Bookmarks", nil) 
                     withItems:nil];
}

#pragma mark -
#pragma Public Methods
-(void)addBookmark:(Location *)bookmark
{
    [self addItem:bookmark];
}

#pragma mark -
#pragma mark Overridden Methods for Editing
//should be overloaded if you want different behavior
-(BOOL)canMoveResultAtIndexPath:(NSIndexPath *)index
{
    return YES;
}

//override for custom behavior
-(DrawableList *)listForSection:(NSUInteger)section
{
    return self;
}

#pragma mark -
#pragma mark AGSCoding

- (void)decodeWithJSON:(NSDictionary *)json
{
    [super decodeWithJSON:json];
    
    self.items = [AGSJSONUtility decodeFromDictionary:json withKey:@"bookmarks" fromClass:[LocationBookmark class]];
}

- (NSDictionary *)encodeToJSON
{
    NSMutableDictionary *json = (NSMutableDictionary *)[super encodeToJSON];
    
    [AGSJSONUtility encodeToDictionary:json withKey:@"bookmarks" AGSCodingArray:self.items];
    
    return json;
}

@end