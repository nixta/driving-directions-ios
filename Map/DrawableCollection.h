//
//  DrawableCollection.h
//  Map
//
//  Created by Scott Sirowy on 9/25/11.
//  Copyright 2011 ESRI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DrawableContainerDelegate.h"

/*
 A drawable collection is a list of drawable lists.
 A collection can be used to populate a results container
 class as it implements the data source for the view controller
 */

@class DrawableList;

@interface DrawableCollection : NSObject <DrawableContainerDataSource>
{
    NSMutableArray *_lists;
    NSUInteger     _currentIndex;
}

@property (nonatomic, assign) NSUInteger    currentIndex;

-(id)initWithList:(DrawableList *)list;
-(id)initWithListArray:(NSArray *)lists;
+(DrawableCollection *)collection;

-(NSUInteger)totalNumberOfItems;
-(NSUInteger)numberOfLists;
-(void)addList:(DrawableList *)list;
-(void)insertList:(DrawableList *)list atIndex:(NSUInteger)index;
-(void)removeListAtIndex:(NSUInteger)index;
-(void)removeListWithName:(NSString *)name;
-(DrawableList *)listAtIndex:(NSUInteger)index;
-(DrawableList *)listWithName:(NSString *)name;
-(id<TableViewDrawable>)itemAtIndex:(NSUInteger)index;
-(BOOL)itemExists:(id<TableViewDrawable>)item;
-(NSUInteger)indexOfItem:(id<TableViewDrawable>)item;
-(void)clear;

@end
