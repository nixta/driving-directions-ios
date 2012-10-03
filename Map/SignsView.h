//
//  SignContainerView.h
//  StreetSignTest
//
//  Created by Scott Sirowy on 11/18/11.
/*
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

/*
 A container that houses a set of street signs that scroll horizontally
 and a tableview that scrolls same information vertically.
 
 A user can see information in both by swiping up and down on screen.
 
 SignsView is a base class and should necessarily be instantiated directly
 */

#import <UIKit/UIKit.h>
#import "PassThroughView.h"
#import "StopsList.h"

@class BlankSignView;
@class DrawableList;
@class SignTableView;
@class SignTableViewCell;

@class    Location;
@protocol NamedGeometry;
@protocol DrawableContainerDataSource; 
@protocol SignsViewDelegate;

@interface SignsView : PassThroughView <UIGestureRecognizerDelegate, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate>
{
    UIScrollView                    *_scrollView;
    SignTableView                   *_tableView;
    id<SignsViewDelegate>           __unsafe_unretained _delegate;
    id<DrawableContainerDataSource> __unsafe_unretained _datasource;
    
    NSUInteger                      _currentPage;
    
    @private
    UIView                          *_signOverlayView;
    UIView                          *__unsafe_unretained _viewToAnimate;
    NSMutableArray                  *_signs;
    SignTableViewCell               *_dummyCell;
    UISwipeGestureRecognizer        *_downSwipeGestureRecognizer;
    
    BOOL                            _expanded;
    CGFloat                         _initialOffset;
}

-(id)initWithOffset:(CGFloat)offset withAdjoiningView:(UIView *)view withDatasource:(id<DrawableContainerDataSource>)datasource;

/*show and hide overlay. This will affect the adjoing view that is initially
 passed in
 */
-(void)setExpanded:(BOOL)expanded animated:(BOOL)animated;

-(BOOL)usesPaging;
-(CGFloat)sizeOfSign;

-(void)setupScrollView;
-(void)setupTableView;

-(void)upSwipeFinished;

-(void)reloadData;

@property (nonatomic, strong) UIScrollView                      *scrollView;
@property (nonatomic, strong) SignTableView                     *tableView;

@property (nonatomic, unsafe_unretained) id<SignsViewDelegate>             delegate;
@property (nonatomic, unsafe_unretained) id<DrawableContainerDataSource>   datasource;


@end


#pragma mark -
#pragma mark Directions Signs View
/*
 Larger signs... Intended for use in an for viewing only... List is fixed
 */
@interface DirectionsSignsView : SignsView {}

/*Manually change to a different result */
-(void)changeToResult:(id<NamedGeometry>)result;

@end

#pragma mark -
#pragma mark Stops Signs View

@protocol EditableSignsDelegate; 

/*
 Smaller signs... Intended for use in an editing scenario. Number of signs is dynamic
 */

@interface StopsSignsView : SignsView <StopsDelegate> {
    
    id<EditableSignsDelegate>   __unsafe_unretained _editDelegate;
    
    @private
    BlankSignView               *_heldSign;
    NSMutableArray              *_signFrames;
    NSUInteger                  _heldIndex;
    NSUInteger                  _originalHeldIndex;
    BOOL                        _modelChangeCameFromMovingSigns;
    
    //for scrolling signs in edit mode
    CGFloat                     _speed;
    CGRect                      _boundingRight;
    CGRect                      _boundingLeft;
    BOOL                        _intersection;
    NSTimer                     *_timer;
}

@property (nonatomic, unsafe_unretained) id<EditableSignsDelegate> editDelegate;

@end


#pragma mark -
#pragma mark Delegate Declarations

/*
 Instructs delegate when signs have been tapped, when view has hidden, expanded, etc
 */
@protocol SignsViewDelegate <NSObject>

@optional

-(void)signsView:(SignsView *)sv didChangeToOrTapOnResult:(id<NamedGeometry>)result;
-(void)signsViewDidExpand:(SignsView *)sv;
-(void)signsViewDidHide:(SignsView *)sv;

@end


/*
 Protocol using delegation that instructs delegate when an edit to the 
 horizontal scrolling street signs has been made
 */

@protocol EditableSignsDelegate <NSObject>

@optional

-(void)stopSignsViewDidCommitEdit:(StopsSignsView *)ssv;

@end


