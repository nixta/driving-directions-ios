//
//  DrawableList.h
//  Map
//
//  Created by Scott Sirowy on 9/25/11.
//  Copyright 2011 ESRI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DrawableContainerDelegate.h"
#import <ArcGIS/ArcGIS.h>

/*
 List of drawable 'TableViewDrawable' items. 
 */

@interface DrawableList : NSObject <DrawableContainerDataSource, AGSCoding>
{
    NSMutableArray  *_items;
    NSString        *_name;
    NSUInteger      _currentIndex;
}

@property (nonatomic, strong, readonly) NSMutableArray  *items;
@property (nonatomic, copy, readonly) NSString          *name;
@property (nonatomic, assign) NSUInteger                currentIndex;

-(id)initWithJSON:(NSDictionary *)json;
-(id)initWithName:(NSString *)name withItems:(NSMutableArray *)items;

-(id<TableViewDrawable>)itemAtIndex:(NSUInteger)index;
-(id<TableViewDrawable>)lastItem;
-(void)addItem:(id<TableViewDrawable>)item;
-(void)removeItem:(id<TableViewDrawable>)item;
-(void)removeItemAtIndex:(NSUInteger)index;
-(void)moveItemAtIndex:(NSUInteger)index1 toIndex:(NSUInteger)index2;
-(void)insertItem:(id<TableViewDrawable>)item atIndex:(NSUInteger)index;
-(void)clear;
-(BOOL)itemExists:(id<TableViewDrawable>)item;
-(NSUInteger)indexOfItem:(id<TableViewDrawable>)item;
-(NSUInteger)numberOfItems;
-(DrawableList *)drawableListFilteredBy:(NSString *)filterString;

@end
