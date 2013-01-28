/*
 Copyright © 2013 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */
#import "DrawableCollection.h"
#import "DrawableList.h"
#import "Location.h"

@interface DrawableCollection () 

@property (nonatomic, strong) NSMutableArray *lists;

@end

@implementation DrawableCollection


+(DrawableCollection *)collection
{
    DrawableCollection *dc = [[DrawableCollection alloc] init];
    return dc;
}

- (id)init
{
    return [self initWithListArray:nil];
}

-(id)initWithList:(DrawableList *)list
{
    return [self initWithListArray:[NSArray arrayWithObject:list]];
}

//Default initializer
-(id)initWithListArray:(NSArray *)lists
{
    self = [super init];
    if (self) {
        self.lists = [NSMutableArray arrayWithArray:lists];
    }
    
    return self;
}

#pragma mark -
#pragma mark Public Methods
//returns number of elements in all 
-(NSUInteger)totalNumberOfItems
{
    NSUInteger total = 0;
    for(DrawableList *dl in self.lists)
    {
        total += [dl numberOfItems];
    }
    return total;
}

-(NSUInteger)numberOfLists
{
    if ( self.lists == nil)
        return 0;
    
    return self.lists.count;
}


-(void)addList:(DrawableList *)list
{
    if (!list)
        return;
    
    [self.lists addObject:list];
}

-(void)insertList:(DrawableList *)list atIndex:(NSUInteger)index
{
    [self.lists insertObject:list atIndex:index];
}

-(void)removeListAtIndex:(NSUInteger)index
{
    if (index >= self.lists.count)
        return;
    
    [self.lists removeObjectAtIndex:index];
}

-(void)removeListWithName:(NSString *)name
{
    DrawableList *dlToRemove = nil;
    for (DrawableList *dl in self.lists)
    {
        if([dl.name isEqualToString:name])
        {
            dlToRemove = dl;
            break;
        }
    }    
    
    [self.lists removeObject:dlToRemove];
}

-(DrawableList *)listAtIndex:(NSUInteger)index
{
    if(index >= self.lists.count)
        return nil;
    
    return [self.lists objectAtIndex:index];
}   

-(DrawableList *)listWithName:(NSString *)name
{
    for (DrawableList *dl in self.lists)
    {
        if([dl.name isEqualToString:name])
        {
            return dl;
        }
    } 
    
    return nil;
}

//returns the item that exists at a particular index. Will span
//across multiples lists in the collection
-(id<TableViewDrawable>)itemAtIndex:(NSUInteger)index
{
    if (index >= [self totalNumberOfItems])
        return nil;
    
    for (DrawableList *dl in self.lists)
    {
        if (index < [dl numberOfItems]) {
            return [dl itemAtIndex:index];
        }
        
        //didnt' find it.  Reduce index and look at next list
        index -= [dl numberOfItems];
    }
    
    //shouldn't get here...
    return nil;
}

-(BOOL)itemExists:(id<TableViewDrawable>)item
{
    for(DrawableList *dl in self.lists)
    {
        if ([dl itemExists:item])
            return YES;
    }
    return NO;
}

//returns the first item where item exists.
-(NSUInteger)indexOfItem:(id<TableViewDrawable>)item
{
    NSUInteger offset = 0;
    for(DrawableList *dl in self.lists)
    {
        NSUInteger listIndex = [dl indexOfItem:item];
        if (listIndex != NSNotFound)
            return listIndex + offset;
        
        offset += [dl numberOfItems];
    }
    
    return NSNotFound;
}

-(void)clear
{
    [self.lists removeAllObjects];
}

-(void)setCurrentIndex:(NSUInteger)currentIndex
{
    if([self numberOfLists] > 1)
        return;
    
    [self listAtIndex:0].currentIndex = currentIndex;
}

#pragma mark -
#pragma mark DrawableContainer Datasource
-(NSUInteger)numberOfResultTypes
{
    return [self numberOfLists];
}

-(NSUInteger)numberOfResultsInSection:(NSUInteger)section
{
    DrawableList *dl = [self.lists objectAtIndex:section];
    return [dl numberOfItems];
}

-(NSString *)titleOfResultTypeForSection:(NSUInteger)section
{
    DrawableList *dl = [self.lists objectAtIndex:section];
    return dl.name;
}

-(id<TableViewDrawable>)resultForRowAtIndexPath:(NSIndexPath *)index
{
    DrawableList *dl = [self.lists objectAtIndex:index.section];
    return [dl itemAtIndex:index.row];
}

//should be overloaded if you want different behavior
-(BOOL)canMoveResultAtIndexPath:(NSIndexPath *)index
{
    return NO;
}

//override for custom behavior
-(DrawableList *)listForSection:(NSUInteger)section
{
    return nil;
}

@end
