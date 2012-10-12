/*
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */
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
