//
//  OverlayViewController.h
//  Map
//
//  Created by Scott Sirowy on 9/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DrawableList;
@class DrawableCollection;
@protocol TableViewDrawable;
@protocol NamedGeometry;
@protocol OverlayViewDelegate;

/*
 Overlay View Controller is a generic view controller to show overlayed
 content on the map that can be swip[ed, interacted with, etc.
 
 Works independently, but also has an interface that can be overridden
 to provide different "skins" for the overlayed content
 */

@interface OverlayViewController : UIViewController <UIScrollViewDelegate>
{
    UIScrollView            *_scrollView;
    
    UIView                  *_viewToAnimate;
    
    id<OverlayViewDelegate> _delegate;
    
    @private
    CGRect                  _initialFrame;
    NSMutableArray          *_views;
    BOOL                    _expanded;
    NSUInteger              _currentPage;
    
    DrawableCollection      *_collection;
}

/*IB Resources */
@property (nonatomic, retain) IBOutlet UIScrollView     *scrollView;

@property (nonatomic, assign) id<OverlayViewDelegate>   delegate;

/*show and hide overlay. This will affect the adjoing view that is initially
 passed in
 */
-(void)setExpanded:(BOOL)expanded animated:(BOOL)animated;

/*Manually change to a different result */
-(void)changeToResult:(id<TableViewDrawable>)result;

-(id)initWithFrame:(CGRect)initialFrame withAdjoiningView:(UIView *)view withDrawableList:(DrawableList *)list;

/*default initializer */
-(id)initWithFrame:(CGRect)initialFrame withAdjoiningView:(UIView *)view withDrawableCollection:(DrawableCollection *)collection;

-(UIView *)viewWithItem:(id<TableViewDrawable>)item;

@end

#pragma mark -
#pragma mark Overlay Delegate
@protocol OverlayViewDelegate <NSObject>

@optional

-(void)overlayViewController:(OverlayViewController *)ovc didChangeToOrTapOnResult:(id<NamedGeometry>)result;
-(void)overlayViewControllerDidExpand:(OverlayViewController *)ovc;
-(void)overlayViewControllerDidHide:(OverlayViewController *)ovc;

@end

#pragma mark -
#pragma mark Street Sign View Controller
@interface StreetSignOverlayViewController : OverlayViewController
@end
