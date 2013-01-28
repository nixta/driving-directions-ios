/*
 Copyright © 2013 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

@interface ContentItem : NSObject <AGSCoding> {
	NSString        *_itemId;
	NSString        *_item;
	NSString        *_itemType;
	NSString        *_contentType;
	NSString        *_title;
	NSString        *_type;
	NSString        *_thumbnail;
    NSString        *_access;
	NSString        *_owner;
	NSInteger       _size;
    NSString        *_description;
    NSString        *_snippet;
    AGSEnvelope     *_extent;
    double          _uploaded;
    NSString        *_name;
    double          _avgRating;
    NSMutableArray  *_tags;
    NSInteger       _numComments;
    NSInteger       _numRatings;
    NSInteger       _numViews;
}

@property (nonatomic, copy) NSString            *itemId;
@property (nonatomic, copy) NSString            *item;
@property (nonatomic, copy) NSString            *itemType;
@property (nonatomic, copy) NSString            *contentType;
@property (nonatomic, copy) NSString            *title;
@property (nonatomic, copy) NSString            *type;
@property (nonatomic, copy) NSString            *access;
@property (nonatomic, copy) NSString            *thumbnail;
@property (nonatomic, copy) NSString            *owner;
@property (nonatomic, assign) NSInteger         size;
@property (nonatomic, copy) NSString            *description;
@property (nonatomic, copy) NSString            *snippet;
@property (nonatomic, strong) AGSEnvelope       *extent;
@property (nonatomic, assign) double            uploaded;
@property (nonatomic, copy) NSString            *name;
@property (nonatomic, assign) double            avgRating;
@property (nonatomic, strong) NSMutableArray    *tags;
@property (nonatomic, assign) NSInteger         numComments;
@property (nonatomic, assign) NSInteger         numRatings;
@property (nonatomic, assign) NSInteger         numViews;

@end
