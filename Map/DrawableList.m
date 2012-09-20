//
//  DrawableList.m
//  Map
//
//  Created by Scott Sirowy on 9/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

/*
 Container class for a list of TableViewDrawable (see protocol) elements
 */

#import "DrawableList.h"
#import "NSDictionary+Additions.h"

@interface DrawableList () 

@property (nonatomic, retain, readwrite) NSMutableArray  *items;
@property (nonatomic, copy, readwrite) NSString          *name;

@end

@implementation DrawableList

@synthesize items = _items;
@synthesize name = _name;
@synthesize currentIndex = _currentIndex;

-(void)dealloc
{
    self.items = nil;
    self.name = nil;
    
    [super dealloc];
}

- (id)init
{
    return [self initWithName:nil withItems:nil];
}

-(id)initWithName:(NSString *)name withItems:(NSMutableArray *)items
{
    self = [super init];
    if(self)
    {
        self.name = name;
        _currentIndex = 0;
        
        if (items)
        {
            self.items = items;
        }
        else
        {
            self.items = [NSMutableArray array];
        }
    }
    
    return self;
}

-(id<TableViewDrawable>)itemAtIndex:(NSUInteger)index
{
    if (index >= self.items.count)
        return nil;
    
    return [self.items objectAtIndex:index];
}

-(id<TableViewDrawable>)lastItem
{
    return [self.items lastObject];
}

-(void)addItem:(id<TableViewDrawable>)item
{
    if (!item)
        return;
    
    [self.items addObject:item];
}

-(void)insertItem:(id<TableViewDrawable>)item atIndex:(NSUInteger)index
{
    if(!item)
        return;
    
    [self.items insertObject:item atIndex:index];
}

-(void)removeItem:(id<TableViewDrawable>)item
{
    if (!item) 
        return;
    
    if ([self.items indexOfObject:item] == NSNotFound)
        return;
    
    [self.items removeObject:item]; 
}


-(void)removeItemAtIndex:(NSUInteger)index
{
    if (index >= self.items.count)
        return;
    
    
    [self.items removeObjectAtIndex:index];
}

-(void)moveItemAtIndex:(NSUInteger)index1 toIndex:(NSUInteger)index2
{
    if (index1 >= self.items.count || index2 >= self.items.count)
        return;
    
    if (index1 == index2)
        return;
    
    id itemToMove = [[self.items objectAtIndex:index1] retain];
    [self.items removeObjectAtIndex:index1];
    
    [self.items insertObject:itemToMove atIndex:index2];
    [itemToMove release]; 
}

-(void)clear
{
    [self.items removeAllObjects];
}

-(BOOL)itemExists:(id<TableViewDrawable>)item
{
    return ([self.items indexOfObject:item] != NSNotFound);
}

-(NSUInteger)indexOfItem:(id<TableViewDrawable>)item
{
    return [self.items indexOfObject:item];
}

-(NSUInteger)numberOfItems
{
    return self.items.count;
}

//Returns a list of the elements contained in this list filtered
//on a filter string
-(DrawableList *)drawableListFilteredBy:(NSString *)filterString
{
    DrawableList *filteredList = [[[DrawableList alloc] initWithName:self.name withItems:nil] autorelease];
    for (id<TableViewDrawable> item in self.items)
    {
        if([item.name rangeOfString:filterString options:NSCaseInsensitiveSearch].location != NSNotFound)
        {
            [filteredList addItem:item];
        }
    }
    
    return filteredList;
}

#pragma mark -
#pragma mark TableViewDrawable Data Source
-(NSUInteger)numberOfResultTypes
{
    return 1;
}

-(NSUInteger)numberOfResultsInSection:(NSUInteger)section
{
    return [self numberOfItems];
}

-(NSUInteger)selectedResultIndex
{
    return self.currentIndex;
}

-(NSString *)titleOfResultTypeForSection:(NSUInteger)section
{
    return nil;
}

-(id<TableViewDrawable>)resultForRowAtIndexPath:(NSIndexPath *)index
{
    return [self itemAtIndex:index.row];
}

//should be overloaded if you want different behavior
-(BOOL)canMoveResultAtIndexPath:(NSIndexPath *)index
{
    return NO;
}

//override for custom behavior
-(DrawableList *)listForSection:(NSUInteger)section
{
    return self;
}

#pragma mark -
#pragma mark AGSCoding

-(id)initWithJSON:(NSDictionary *)json
{
    self = [self init];
    if (self) {
        [self decodeWithJSON:json];
    }
    return self;
}

//Should be overridden for list-specific behavior for items!
- (void)decodeWithJSON:(NSDictionary *)json
{
    self.name = [AGSJSONUtility getStringFromDictionary:json withKey:@"name"];
    
    NSNumber *currentIndex = [json valueForKey:@"currentIndex"];
    if (!isnan([currentIndex intValue])) {
        self.currentIndex = [currentIndex intValue];
    }
}

//Should be overridden for list-specific behavior for items!
- (NSDictionary *)encodeToJSON
{
    NSMutableDictionary *json = [NSMutableDictionary dictionaryWithCapacity:3];
    
	[NSDictionary safeSetObjectInDictionary:json object:self.name withKey:@"name"];
    
    [json setObject:[NSNumber numberWithInt:self.currentIndex] forKey:@"currentIndex"];
    
    return json;
}

@end
