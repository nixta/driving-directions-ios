//
//  SignContainerView.m
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

#import "SignsView.h"
#import "BlankSignView.h"
#import <QuartzCore/QuartzCore.h>
#import "DrawableList.h"
#import "SignTableView.h"
#import "StreetSignView.h"
#import "StopSignView.h"
#import "Direction.h"
#import "SignTableViewCell.h"
#import "Location.h"
#import "CurrentLocation.h"
#import "StopsList.h"

#define kWidthOfBigSign 300.0
#define kAnimationDuration .1
#define kSwipeAnimationLength .4
#define kMoveAnimationLength .4
#define kScrollAnimationLength .3
#define kSignHeight 85.0
#define kShadowSlope 1.7
#define kToolbarHeight 44
#define kTopBottomMargins 10.0
#define kEditingConstant 20.0

#define kDirectionPlaceSection 0

@interface SignsView () 

-(void)upSwipe:(UISwipeGestureRecognizer *)sgr;
-(void)downSwipe:(UISwipeGestureRecognizer *)sgr;

@property (nonatomic, strong) NSMutableArray            *signs;
@property (nonatomic, unsafe_unretained) UIView                    *viewToAnimate;
@property (nonatomic, strong) UIView                    *signOverlayView;
@property (nonatomic, strong) UISwipeGestureRecognizer  *downSwipeGestureRecognizer;

@property (nonatomic, strong) SignTableViewCell         *dummyCell;

@end

@implementation SignsView

@synthesize scrollView                  = _scrollView;
@synthesize tableView                   = _tableView;
@synthesize signs                       = _signs;

@synthesize viewToAnimate               = _viewToAnimate;
@synthesize delegate                    = _delegate;
@synthesize datasource                  = _datasource;
@synthesize signOverlayView             = _signOverlayView;

@synthesize downSwipeGestureRecognizer  = _downSwipeGestureRecognizer;
@synthesize dummyCell                   = _dummyCell;



#pragma mark -
#pragma mark Initialization Stuff
-(id)initWithOffset:(CGFloat)offset withAdjoiningView:(UIView *)view withDatasource:(id<DrawableContainerDataSource>)datasource
{
    CGRect rect = CGRectMake(0, 0, 320, 416);
    rect.origin.y = offset;
    
    self = [super initWithFrame:rect];
    
    if(self)
    {
        _initialOffset = offset;
        
        self.viewToAnimate = view;
        self.datasource = datasource;
        
        UISwipeGestureRecognizer *upRecognizer;
        upRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(upSwipe:)];
        [upRecognizer setDirection:UISwipeGestureRecognizerDirectionUp];
        [self addGestureRecognizer:upRecognizer];
        
        NSUInteger numSigns = [self.datasource numberOfResultsInSection:kDirectionPlaceSection];
        self.signs = [NSMutableArray arrayWithCapacity:numSigns];
    }
    
    return self;
}

#pragma mark -
#pragma mark Drawing Initialization
-(void)layoutSubviews
{
    
    
    if (self.scrollView.superview == nil) {
        [self setupScrollView];
    }
    
    if(self.tableView.superview == nil)
    {
        //perform after run loop so we can get cool shadow effect from
        //the street signs above it!
        [self performSelector:@selector(setupTableView) withObject:nil afterDelay:0.0];
    }
}

#pragma mark -
#pragma mark Lazy Loads
-(UIScrollView *)scrollView
{
    if(_scrollView == nil)
    {
        UIScrollView *sv = [[UIScrollView alloc] initWithFrame:CGRectMake(12, 0, kWidthOfBigSign, kSignHeight)];
        
        //Configure scroll view   
        sv.pagingEnabled = [self usesPaging];
        sv.bounces = YES;
        
        sv.showsVerticalScrollIndicator = NO;
        sv.showsHorizontalScrollIndicator = NO;
        sv.delegate = self;
        sv.clipsToBounds = NO;
        
        self.scrollView = sv;
    }
    return _scrollView;
}

-(SignTableView *)tableView
{
    if(_tableView == nil)
    {
        SignTableView *bigStreetSignView = [[SignTableView alloc] initWithFrame:CGRectMake(0, kSignHeight, self.frame.size.width, self.frame.size.height-kSignHeight) 
                                                                     dataSource:self 
                                                                       delegate:self];
        
        bigStreetSignView.backgroundColor = [UIColor clearColor];
        bigStreetSignView.reflectionSlope = kShadowSlope;
        self.tableView = bigStreetSignView;
    }
    return _tableView;
}

#pragma mark -
#pragma mark Scrolling

/*Default implementation. Override if needed */
-(BOOL)usesPaging
{
    return NO;
}

/*Default. Override if needed */
-(CGFloat)sizeOfSign
{
    return 0;
}

#pragma mark -
#pragma mark UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{	
    // Calculate which page is visible 
	CGFloat pageWidth = self.scrollView.frame.size.width;
	_currentPage = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.datasource numberOfResultsInSection:kDirectionPlaceSection];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //should probably be overridden
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"Cell";
    
    SignTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[SignTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    return cell;
}

#pragma mark -
#pragma mark Swipe Gesture Recognizers
-(void)upSwipe:(UISwipeGestureRecognizer *)recognizer {
    
    if (self.signOverlayView.superview == nil) {
        [self addSubview:self.signOverlayView];
        [self.signOverlayView addGestureRecognizer:self.downSwipeGestureRecognizer];
    }
    
    CGRect viewFrame = self.frame;
    viewFrame.origin.y = kToolbarHeight;
    
    [self.tableView reloadData];
    
    [UIView animateWithDuration:kSwipeAnimationLength 
                     animations:^{
                         self.frame = viewFrame;
                     }
                     completion:^(BOOL finished)
     {
         [self performSelector:@selector(upSwipeFinished) withObject:nil afterDelay:0.0];
     }
     ];
}

//Override if you any custom behavior is desired after up swipe is complete
-(void)upSwipeFinished
{
    
}

-(void)downSwipe:(UISwipeGestureRecognizer *)recognizer {
    
    CGRect viewFrame = self.frame;
    viewFrame.origin.y = _initialOffset - (kSignHeight + kTopBottomMargins);
    
    self.scrollView.clipsToBounds = NO;
    
    //Fix for swipe gesture recognizer. Likes to register a swipe if the 
    //the view its associated with is removed. 
    //http://stackoverflow.com/questions/4226239/uiswipegesturerecognizer-called-twice
    
    [self.signOverlayView removeGestureRecognizer:self.downSwipeGestureRecognizer];
    [self.signOverlayView removeFromSuperview];
    
    [UIView animateWithDuration:kSwipeAnimationLength 
                     animations:^{
                         self.frame = viewFrame;
                     }
    ];
}


#pragma mark -
#pragma mark Long Press Gesture Delegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    //return (_state == SignContainerStateSmallSigns);
    return ![gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]];
}

#pragma mark -
#pragma mark Public Methods
-(void)setExpanded:(BOOL)expanded animated:(BOOL)animated
{
    if (_expanded == expanded)
        return;
    
	_expanded = expanded;
	
    CGRect myRect = self.frame;
    
	if (_expanded){
        
        myRect.origin.y = _initialOffset - (kSignHeight + kTopBottomMargins);
        
        CGRect adjoiningRect = self.viewToAnimate.frame;
        adjoiningRect.origin.y -= (kSignHeight + kTopBottomMargins);
        
        if(animated)
        {
            [UIView animateWithDuration:0.5 
                             animations:^{
                                 self.frame = myRect;
                                 self.viewToAnimate.frame = adjoiningRect;
                                 
                             }
                             completion:^(BOOL finished)
             {
                 if([self.delegate respondsToSelector:@selector(signsViewDidExpand:)])
                 {
                     [self.delegate signsViewDidExpand:self];
                 }
             }
             ];
        }
        else
        {
            self.frame = myRect;
            self.viewToAnimate.frame = adjoiningRect;
            
            if ([self.delegate respondsToSelector:@selector(signsViewDidExpand:)]) {
                [self.delegate signsViewDidExpand:self];
            }
        }
	}
	else {
        myRect.origin.y = _initialOffset;
        
        CGRect adjoiningRect = self.viewToAnimate.frame;
        adjoiningRect.origin.y += (kSignHeight + kTopBottomMargins);
        
        if(animated)
        {
            [UIView animateWithDuration:0.5 
                             animations:^{
                                 self.frame = myRect;
                                 self.viewToAnimate.frame = adjoiningRect;
                                 
                             }
                             completion:^(BOOL finished)
             {
                 if ([self.delegate respondsToSelector:@selector(signsViewDidHide:)]) {
                     [self.delegate signsViewDidHide:self];
                 }
             }
             ];
        }
        else
        {
            self.frame = myRect;
            self.viewToAnimate.frame = adjoiningRect;
            
            if ([self.delegate respondsToSelector:@selector(signsViewDidHide:)]) {
                [self.delegate signsViewDidHide:self];
            }
        }	
    }
}

-(void)reloadData
{
    [self.tableView reloadData];
}


#pragma mark -
#pragma mark Ux Configuration. Empty here. Should be overridden
-(void)setupScrollView
{
}

-(void)setupTableView
{
}

#pragma mark -
#pragma mark Lazy Loads
-(SignTableViewCell *)dummyCell
{
    if(_dummyCell == nil)
    {
        SignTableViewCell *tvc = [[SignTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        self.dummyCell = tvc;
    }
    
    return _dummyCell;
}

-(UIView *)signOverlayView
{
    if(_signOverlayView == nil)
    {
        UIView *v = [[UIView alloc] initWithFrame:self.scrollView.frame];
        
        UITapGestureRecognizer *tapRecognizer;
        tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(downSwipe:)];
        tapRecognizer.numberOfTapsRequired = 1;
        [v addGestureRecognizer:tapRecognizer]; 
        
        //also add a down swipe recognizer, but due to a bug in Apple's implementation (I think)
        //we have to add and remove everytime the sign overlay is added and removed from hierarchy
        
        v.backgroundColor = [UIColor clearColor];
        
        self.signOverlayView = v;
    }
    
    return _signOverlayView;
}

-(UISwipeGestureRecognizer *)downSwipeGestureRecognizer
{
    if(_downSwipeGestureRecognizer == nil)
    {
        UISwipeGestureRecognizer *downRecognizer;
        downRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(downSwipe:)];
        [downRecognizer setDirection:UISwipeGestureRecognizerDirectionDown];
        
        self.downSwipeGestureRecognizer = downRecognizer;
    }
    
    return _downSwipeGestureRecognizer;
}

@end



#pragma mark -
#pragma mark Directions Signs View

@interface DirectionsSignsView () 

-(void)manuallyScrollToPage:(NSUInteger)page;
-(void)loadScrollViewWithPage:(int)page;

-(void)resultChangedTo:(NSUInteger)index;
-(UIView *)viewWithItem:(id<TableViewDrawable>)item;

@end

@implementation DirectionsSignsView

-(id)initWithOffset:(CGFloat)offset withAdjoiningView:(UIView *)view withDatasource:(id<DrawableContainerDataSource>)datasource
{
    self = [super initWithOffset:offset withAdjoiningView:view withDatasource:datasource];
    if(self)
    {
        for (unsigned i = 0; i < [self.datasource numberOfResultsInSection:kDirectionPlaceSection]; i++)
        {
            [self.signs addObject:[NSNull null]];
        } 
    }
    
    return self;
}

#pragma mark -
#pragma mark Ux Configuration
-(UIView *)viewWithItem:(id<TableViewDrawable>)item
{
    Direction *direction = (Direction *)item;
    
    StreetSignView *ssv = [[StreetSignView alloc] initWithFrame:self.scrollView.frame 
                                                   withDirection:direction                                             
                                             withReflectionSlope:kShadowSlope 
                                                       startingX:245 
                                                       useShadow:YES];
    
    ssv.backgroundColor = [UIColor clearColor];
    
    return ssv;
}

-(void)setupScrollView
{
    if(self.scrollView.superview == nil)
    {
        [self addSubview:self.scrollView];
        
        CGFloat width = [self.datasource numberOfResultsInSection:kDirectionPlaceSection]*self.sizeOfSign;
        self.scrollView.contentSize = CGSizeMake(width, kSignHeight);
        
        [self loadScrollViewWithPage:0];
        [self loadScrollViewWithPage:1];
    }
}

-(void)setupTableView
{
    if(self.tableView.superview == nil)
    {
        StreetSignView *ssv = (StreetSignView *)[self.signs objectAtIndex:0];
        self.tableView.xShadow = isnan(ssv.xIntercept) ? 0 : ssv.xIntercept + 10; 
        [self.tableView setDelegate:self];
        
        //add after setting shadow so shadow correctly draws
        [self addSubview:self.tableView];
    } 
}

#pragma mark -
#pragma mark Gesture Recognizer Overrides
-(void)upSwipeFinished
{
    self.scrollView.clipsToBounds = YES;
}

#pragma mark -
#pragma mark Scrolling
-(void)loadScrollViewWithPage:(int)page
{
    if (page < 0)
        return;
    if (page >= [self.datasource numberOfResultsInSection:kDirectionPlaceSection])
        return;
    
    // replace the placeholder if necessary
    UIView *view = [self.signs objectAtIndex:page];
    if ((NSNull *)view == [NSNull null])
    {
        NSIndexPath *ip = [NSIndexPath indexPathForRow:page inSection:kDirectionPlaceSection];
        view = [self viewWithItem:[self.datasource resultForRowAtIndexPath:ip]];

        //replace in views array
        [self.signs replaceObjectAtIndex:page withObject:view];
    }
    
    // add the controller's view to the scroll view
    if (view.superview == nil)
    {
		CGRect viewFrame = view.frame;
		viewFrame.origin.x = self.sizeOfSign * page;  
		view.frame = viewFrame;
        
        [self.scrollView addSubview:view];
    }
}

-(void)resultChangedTo:(NSUInteger)index
{
    DrawableList *placeDirectionList = [self.datasource listForSection:kDirectionPlaceSection];
    //update list index
    placeDirectionList.currentIndex = index;
    
    //inform anyone who is interested
    if([self.delegate respondsToSelector:@selector(signsView:didChangeToOrTapOnResult:)])
    {
        id<NamedGeometry> ng = nil;
        id result = [placeDirectionList itemAtIndex:index];
        if ([result conformsToProtocol:@protocol(NamedGeometry)]) {
            ng = (id<NamedGeometry>)result;
        }
        
        [self.delegate signsView:self didChangeToOrTapOnResult:ng];
    }
}

-(void)manuallyScrollToPage:(NSUInteger)page
{    
    if (page >= [self.datasource numberOfResultsInSection:kDirectionPlaceSection])
        return;
    
    CGFloat svWidth = self.scrollView.frame.size.width;
    CGFloat svHeight = self.scrollView.frame.size.height;
    
    [self.scrollView scrollRectToVisible:CGRectMake(page*svWidth, 0, svWidth, svHeight) animated:YES];
}

-(void)changeToResult:(id<NamedGeometry>)result
{
    id<TableViewDrawable> tvd = (id<TableViewDrawable>)result;
    
    DrawableList *listOfPlacesDirections = [self.datasource listForSection:kDirectionPlaceSection];
    
    if ([listOfPlacesDirections itemExists:tvd]) {
        NSUInteger newPage = [listOfPlacesDirections indexOfItem:tvd];
        
        [self manuallyScrollToPage:newPage];
        [self resultChangedTo:newPage];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadScrollViewWithPage:_currentPage-1];
    [self loadScrollViewWithPage:_currentPage];
    [self loadScrollViewWithPage:_currentPage+1];
    
    [self resultChangedTo:_currentPage];
}

#pragma mark -
#pragma mark UITableViewDataSource
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Direction *dir = (Direction *)[self.datasource resultForRowAtIndexPath:indexPath];
    
    CGSize constrainedSize = CGSizeMake(self.dummyCell.nameLabel.bounds.size.width, 10000);
    
    CGSize newSize = [dir.abbreviatedName sizeWithFont:self.dummyCell.nameLabel.font 
                                     constrainedToSize:constrainedSize lineBreakMode:UILineBreakModeCharacterWrap];
    
    return newSize.height + (2*kTopBottomMargins);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SignTableViewCell *cell = (SignTableViewCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    Direction *dir = (Direction *)[self.datasource resultForRowAtIndexPath:indexPath];
    cell.distanceLabel.text = dir.distanceString;
    cell.iconImageView.image = dir.icon;
    cell.nameLabel.text = dir.abbreviatedName;

# warning Testing a different color for highlighted direction
    /*
     if (indexPath.row == 1) {
     //cell.view.backgroundColor = [UIColor colorWithRed:(253.0/255.0) green:(218.0/255.0) blue:(113.0/255.0) alpha:1.0];
     cell.view.backgroundColor = [UIColor colorWithRed:(192.0/255.0) green:(192.0/255.0) blue:(192.0/255.0) alpha:1.0];
     cell.distanceLabel.textColor = [UIColor blackColor];
     cell.nameLabel.textColor = [UIColor blackColor];
     }
     else{
     cell.view.backgroundColor = [UIColor clearColor];
     cell.distanceLabel.textColor = [UIColor whiteColor];
     cell.nameLabel.textColor = [UIColor whiteColor];
     } */
    
    CGRect cellFrame = cell.view.frame;
    CGRect nameFrame = cell.nameLabel.frame;
    
    CGSize constrainedSize = CGSizeMake(self.dummyCell.nameLabel.bounds.size.width, 10000);
    
    CGSize newSize = [dir.abbreviatedName sizeWithFont:self.dummyCell.distanceLabel.font 
                                     constrainedToSize:constrainedSize 
                                         lineBreakMode:UILineBreakModeCharacterWrap];
    
    cellFrame.size.height = newSize.height + (2*kTopBottomMargins);
    
    nameFrame.size.height = newSize.height;
    nameFrame.origin.y = (cellFrame.size.height - nameFrame.size.height)/2;
    
    cell.view.frame = cellFrame;
    cell.frame = cellFrame;
    cell.nameLabel.frame = nameFrame; 
    
    return cell;
}


#pragma mark -
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self downSwipe:nil];
    [self resultChangedTo:indexPath.row];
    
    [self loadScrollViewWithPage:indexPath.row -1];
    [self loadScrollViewWithPage:indexPath.row];
    [self loadScrollViewWithPage:indexPath.row +1];
    
    [self manuallyScrollToPage:indexPath.row];
}


/*Overidden implementation */
-(BOOL)usesPaging
{
    return YES;
}

/*Overridden Implementation */
-(CGFloat)sizeOfSign
{
    return (kWidthOfBigSign);
}

@end

#pragma mark -
#pragma mark Stops Signs View

@interface StopsSignsView () 

//Animating Stuff for Smaller Signs
-(void)startWigglingSigns;
-(void)stopWigglingSigns;
-(void)initializeScrollViewWithSigns;
-(void)updateSignsAndFramesAnimated:(BOOL)animated;
-(void)addSignForLocation:(Location *)l atIndex:(NSUInteger)index;
-(void)moveStopFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;
-(CGSize)minSize:(CGSize)size;

-(void)moveUnheldTilesAwayFromPoint:(CGPoint)location;
-(int)indexOfClosestFrameToPoint:(CGPoint)point;
-(int)frameIndexForTileIndex:(int)tileIndex;
-(void)scrollSigns;

//properties for editing signs in place
@property (nonatomic, strong) BlankSignView     *heldSign;
@property (nonatomic, strong) NSMutableArray    *signFrames;
@property (nonatomic, assign) NSUInteger        heldIndex;
@property (nonatomic, strong) NSTimer           *timer;

@end

@implementation StopsSignsView

@synthesize editDelegate    = _editDelegate;

@synthesize heldSign        = _heldSign;
@synthesize signFrames      = _signFrames;
@synthesize heldIndex       = _heldIndex;
@synthesize timer           = _timer;



#define kWidthOfSmallSign 130.0
-(CGFloat)sizeOfSign
{
    return (kWidthOfSmallSign);
}

//will return a minimum size that the scrollview can take if the calculated one is too small
-(CGSize)minSize:(CGSize)size
{
    if (size.width < (3*self.sizeOfSign)) {
        size.width = (3*self.sizeOfSign);
    }
    
    size.height = kSignHeight;
    
    return size;
}

-(void)setupScrollView
{
    if(self.scrollView.superview == nil)
    {
        [self addSubview:self.scrollView];
        
        //add all of the signs
        [self initializeScrollViewWithSigns];
        
        _boundingLeft = _boundingRight = CGRectMake(0, 0, self.sizeOfSign, kSignHeight);
        _boundingRight.origin = CGPointMake(self.scrollView.frame.size.width, self.scrollView.frame.origin.y);
        _boundingLeft.origin = CGPointMake(self.scrollView.frame.origin.x - self.sizeOfSign, self.scrollView.frame.origin.y);
    }
}

-(void)initializeScrollViewWithSigns
{   
    NSUInteger numberOfSigns = [self.datasource numberOfResultsInSection:kDirectionPlaceSection];
    self.signFrames = [NSMutableArray arrayWithCapacity:numberOfSigns];
    
    for (int i = 0; i < numberOfSigns; i++) {
        NSIndexPath *ip = [NSIndexPath indexPathForRow:i inSection:kDirectionPlaceSection];
        Location *l = (Location *)[self.datasource resultForRowAtIndexPath:ip];
        [self addSignForLocation:l atIndex:i];
    }
}

-(void)setupTableView
{
    if(self.tableView.superview == nil)
    {
        self.tableView.xShadow = self.frame.size.width/2; 
        [self addSubview:self.tableView];
        
        //go into permanent editing mode!
        [self.tableView setEditing:YES animated:NO];
    } 
}

-(void)moveStopFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    StopsList *stopsList = (StopsList *)[self.datasource listForSection:kDirectionPlaceSection];
    [stopsList moveItemAtIndex:fromIndex toIndex:toIndex]; 
    
    if([self.editDelegate respondsToSelector:@selector(stopSignsViewDidCommitEdit:)])
    {
        [self.editDelegate stopSignsViewDidCommitEdit:self];
    }
}

#pragma mark -
#pragma mark UITableViewDataSource

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Location *loc = (Location *)[self.datasource resultForRowAtIndexPath:indexPath];
    
    CGSize constrainedSize = CGSizeMake(self.dummyCell.nameLabel.bounds.size.width, 10000);
    
    CGSize newSize = [[loc searchString] sizeWithFont:self.dummyCell.nameLabel.font 
                          constrainedToSize:constrainedSize lineBreakMode:UILineBreakModeCharacterWrap];
    
    return newSize.height + (2*kTopBottomMargins);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SignTableViewCell *cell = (SignTableViewCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];

    Location *loc = (Location *)[self.datasource resultForRowAtIndexPath:indexPath];
    cell.iconImageView.image = loc.icon;
    cell.nameLabel.text = [loc searchString];
    
    BOOL isCurrentLoc = ([loc isKindOfClass:[CurrentLocation class]]);
    cell.isCurrentLocation = isCurrentLoc;
    cell.nameLabel.font = isCurrentLoc ? [UIFont fontWithName:@"Verdana-Italic" size:14.0] : self.dummyCell.nameLabel.font;
    

    CGRect cellFrame = cell.view.frame;
    CGRect nameFrame = cell.nameLabel.frame;
    
    CGSize constrainedSize = CGSizeMake(self.dummyCell.nameLabel.bounds.size.width, 10000);
    
    CGSize newSize = [cell.nameLabel.text sizeWithFont:self.dummyCell.nameLabel.font 
                                     constrainedToSize:constrainedSize 
                                         lineBreakMode:UILineBreakModeCharacterWrap];
    
    cellFrame.size.height = newSize.height + (2*kTopBottomMargins);
    
    nameFrame.size.height = newSize.height;
    nameFrame.origin.y = (cellFrame.size.height - nameFrame.size.height)/2;
    
    cell.view.frame = cellFrame;
    cell.frame = cellFrame;
    cell.nameLabel.frame = nameFrame; 
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.datasource canMoveResultAtIndexPath:indexPath];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.datasource canMoveResultAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath 
{
    if (fromIndexPath == toIndexPath)
        return;
    
    [self moveStopFromIndex:fromIndexPath.row toIndex:toIndexPath.row];
    
    [self reloadData];
}

-(NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath 
      toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    StopsList *stopsList = (StopsList *)[self.datasource listForSection:proposedDestinationIndexPath.section];
    Location *loc = [stopsList stopAtIndex:proposedDestinationIndexPath.row];
    
    if ([loc isKindOfClass:[CurrentLocation class]]) {
        return sourceIndexPath;
    }
    
    return proposedDestinationIndexPath;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    StopsList *stopsList = (StopsList *)[self.datasource listForSection:indexPath.section];
    [stopsList removeStopAtIndex:indexPath.row];
    
    if([self.editDelegate respondsToSelector:@selector(stopSignsViewDidCommitEdit:)])
    {
        [self.editDelegate stopSignsViewDidCommitEdit:self];
    }
    
    //trying to delete the start location... In this case, we need to remove the stop and immediately 
    //reload the tableview since we are replacing the intended start with a "Current Location" filler
    if(indexPath.row == 0)
    {
        [self reloadData];
    }
    else
    {
        //show delete animation
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
                              withRowAnimation:UITableViewRowAnimationFade];
        
        //reload data so symbols update slightly after animation is finished
        [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
    }
}

#pragma mark -
#pragma mark StopsDelegate
-(void)stopsList:(StopsList *)sl addedStop:(Location *)location atIndex:(NSUInteger)index
{
    if (self.signs.count == 0) {
        [self initializeScrollViewWithSigns];
    }
    else
    {
        [self addSignForLocation:location atIndex:index];
        [self updateSignsAndFramesAnimated:YES];
    }
}

-(void)stopsList:(StopsList *)sl removedStop:(Location *)location atIndex:(NSUInteger)index
{
    //removing their start location... keep same size scroll view, but change to default current location
    if (index == 0) {
        NSIndexPath *ip = [NSIndexPath indexPathForRow:0 inSection:kDirectionPlaceSection];
        Location *cl = (Location *)[self.datasource resultForRowAtIndexPath:ip];
        
        StopSignView *ssv = [self.signs objectAtIndex:0];
        ssv.location = cl;
    }
    //removed any other sign... Decrease size of scroll view and remove sign from view
    else
    {        
        //don't need last frame anymore
        [self.signFrames removeLastObject];
        
        //remove from scrollview and sign array
        StopSignView *ssv = [self.signs objectAtIndex:index];
        [ssv removeFromSuperview];
        [self.signs removeObject:ssv];
        
        CGSize size = self.scrollView.contentSize;
        size.width = self.sizeOfSign*self.signs.count;
        self.scrollView.contentSize = [self minSize:size];
        
        [self updateSignsAndFramesAnimated:YES];
    }
}

-(void)stopsList:(StopsList *)sl movedStop:(Location *)location fromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex trueMove:(BOOL)trueMove
{
    //if the signs initiated the move, ignore call.
    if (_modelChangeCameFromMovingSigns) {
        _modelChangeCameFromMovingSigns = NO;
        return;
    }
    
    //Move signs to reflect the change
    id itemToMove = [self.signs objectAtIndex:fromIndex];
    [self.signs removeObjectAtIndex:fromIndex];
    
    //They are changing the start location. If this is not a true move, add a new sign for the current location
    if (fromIndex == 0 && !trueMove) {
        Location *newStartLoc = (Location *)[self.datasource resultForRowAtIndexPath:[NSIndexPath indexPathForRow:fromIndex 
                                                                                                        inSection:kDirectionPlaceSection]];
        
        [self addSignForLocation:newStartLoc atIndex:0];
    }
    
    //perform move        
    [self.signs insertObject:itemToMove atIndex:toIndex];
    
    [self updateSignsAndFramesAnimated:YES];
}

-(void)stopsList:(StopsList *)sl movedStop:(Location *)location fromIndex:(NSUInteger)fromIndex toReplaceStop:(Location *)loc atIndex:(NSUInteger)index
{
    id itemToMove = [self.signs objectAtIndex:fromIndex];
    [self.signs removeObjectAtIndex:fromIndex];
        
    //perform move        
    [self.signs replaceObjectAtIndex:index withObject:itemToMove];
    
    CGSize size = self.scrollView.contentSize;
    size.width = self.sizeOfSign*self.signs.count;
    self.scrollView.contentSize = [self minSize:size];
    
    [self updateSignsAndFramesAnimated:YES]; 
}

-(void)stopsList:(StopsList *)sl replacedStop:(Location *)stop1 withStop:(Location *)stop2 atIndex:(NSUInteger)index
{
    if (self.signs.count == 0) {
        [self initializeScrollViewWithSigns];
    }
    else
    {
        NSIndexPath *ip = [NSIndexPath indexPathForRow:index inSection:kDirectionPlaceSection];
        Location *loc = (Location *)[self.datasource resultForRowAtIndexPath:ip];
        
        StopSignView *ssv = [self.signs objectAtIndex:index];
        ssv.location = loc;
    }
}

-(void)updateSignsAndFramesAnimated:(BOOL)animated;
{
    if (animated) {
        [UIView animateWithDuration:kMoveAnimationLength animations:^{
            //update frames for rest of signs
            for (int i = 0; i < self.signs.count; i++) {
                StopSignView *ssv = [self.signs objectAtIndex:i];
                ssv.frame = [[self.signFrames objectAtIndex:i] CGRectValue];
            }
        }completion:^(BOOL completed)
         {
             //redraw all of the signs... Also update their index
             int i = 0;
             for (StopSignView *ssv in self.signs)
             {
                 [ssv setNeedsLayout];
                 ssv.index = i++;
             }
         }
         ];
    }
    //unanimated versions
    else
    {
        for (int i = 0; i < self.signs.count; i++) {
            StopSignView *ssv = [self.signs objectAtIndex:i];
            ssv.frame = [[self.signFrames objectAtIndex:i] CGRectValue];
        }
        
        //redraw all of the signs!
        for (StopSignView *ssv in self.signs)
        {
            [ssv setNeedsLayout];
        }
    }
}

//helper method
-(void)addSignForLocation:(Location *)l atIndex:(NSUInteger)index
{    
    //add a new frame to sign frames array since user added a stop
    CGRect newFrame = CGRectMake(self.sizeOfSign * self.signFrames.count, 0, self.sizeOfSign, kSignHeight);
    [self.signFrames addObject:[NSValue valueWithCGRect:newFrame]];
    
    //create new sign...
    StopSignView  *ssv = [[StopSignView alloc] initWithFrame:[[self.signFrames objectAtIndex:index] CGRectValue] 
                                                withLocation:l];
    ssv.backgroundColor = [UIColor clearColor];
    
    ssv.index = index;
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressRecognized:)];
    lpgr.minimumPressDuration = 0.3;
    lpgr.delegate = self;
    [ssv addGestureRecognizer:lpgr];
    
    [self.signs insertObject:ssv atIndex:index];
    [self.scrollView addSubview:ssv];
    
    CGSize size = self.scrollView.contentSize;
    size.width = self.sizeOfSign*self.signs.count;
    self.scrollView.contentSize = [self minSize:size];
}

#pragma mark -
#pragma mark Tap and Hold Gesture Recognizer
-(void)longPressRecognized:(UILongPressGestureRecognizer *)longPressGestureRecognizer
{    
    
    BlankSignView *bsv = (BlankSignView *)longPressGestureRecognizer.view;
    
    CGPoint location = [longPressGestureRecognizer locationInView:self.scrollView];
    
    switch (longPressGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            self.heldSign = bsv;
            _heldIndex = _originalHeldIndex = [self frameIndexForTileIndex:self.heldSign.index];
            [self.heldSign appearDraggable];
            [self startWigglingSigns];
            break;
        case UIGestureRecognizerStateChanged:
            bsv.center = location;
            [self moveUnheldTilesAwayFromPoint:location];
          
            /*
             Next if/else block is trying to determine if the user has dragged the
             sign over to the side of the screen... If so, then user a timer to slowly 
             scroll the signs over to the right or left
             */
            CGRect rectInSuper = [self convertRect:bsv.frame fromView:self.scrollView];
            
            CGRect int1Rect = CGRectIntersection(rectInSuper, _boundingRight);
            CGRect int2Rect = CGRectIntersection(rectInSuper, _boundingLeft);
            
            // r1 positive
            // r2 negative
            
            if (!CGRectIsEmpty(int1Rect)) {
                
                // intersection right
                CGFloat totalW = CGRectGetWidth(bsv.frame);
                CGFloat w = CGRectGetWidth(int1Rect);
                CGFloat percent = w/totalW;
                
                if (percent < 0.33f) {
                    _speed = 3;
                }
                else if (percent >= 0.33f && percent < 0.67) {
                    _speed = 2;
                }
                else {
                    _speed = 1;
                }
                
                if (!self.timer) {
                    self.timer = [NSTimer scheduledTimerWithTimeInterval:kScrollAnimationLength target:self selector:@selector(scrollSigns) userInfo:nil repeats:YES];            
                }
                
                
            } 
            else if (!CGRectIsEmpty(int2Rect)) {
                
                // intersection left
                CGFloat totalW = CGRectGetWidth(rectInSuper);
                CGFloat w = CGRectGetWidth(int2Rect);
                CGFloat percent = w/totalW;
                
                if (percent < 0.33f) {
                    _speed = -3;
                }
                else if (percent >= 0.33f && percent < 0.67) {
                    _speed = -3;
                }
                else {
                    _speed = -1;
                }
                
                if (!self.timer) {
                    self.timer = [NSTimer scheduledTimerWithTimeInterval:kScrollAnimationLength target:self selector:@selector(scrollSigns) userInfo:nil repeats:YES];            
                }
                
            }
            else
            {
                [self.timer invalidate];
                self.timer = nil;
            }
            
            break;
        case UIGestureRecognizerStateEnded:
            [self stopWigglingSigns];
            [self.heldSign appearNormal];
            
            [self.timer invalidate];
            self.timer = nil;
            _intersection = NO;
            _speed = 0;
            
            //if user actually moved a sign, we need to update model
            if (_originalHeldIndex != _heldIndex) {                
                //by altering the model, we will receive a delegate method
                //stating that all views for the model need to be changed... But,
                //since we initiated the change, we will need to ignore the 
                //delegate callback
                _modelChangeCameFromMovingSigns = YES;
                
                //now call method that will initiate a model change
                [self moveStopFromIndex:_originalHeldIndex toIndex:_heldIndex];
                
                [self updateSignsAndFramesAnimated:NO];
            }
            
            [UIView animateWithDuration:kAnimationDuration animations:^{
                self.heldSign.frame = [[self.signFrames objectAtIndex:_heldIndex] CGRectValue];
            }
             ];
            
            self.heldSign = nil;
            break;
        
    }
}


#pragma mark -
#pragma mark Long Press Gesture Delegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    StopSignView *ssv = (StopSignView *)gestureRecognizer.view;
    return ssv.editable;
}

- (void)moveUnheldTilesAwayFromPoint:(CGPoint)location {
    int frameIndex = [self indexOfClosestFrameToPoint:location];
    
    BlankSignView *viewToMove = [self.signs objectAtIndex:frameIndex];
    
    //this will only happen if we have a current location sign on the screen
    if (!viewToMove.editable)
        return;
    
    if (frameIndex != _heldIndex){
        [UIView animateWithDuration:kAnimationDuration animations:^{
            viewToMove.frame = [[self.signFrames objectAtIndex:_heldIndex] CGRectValue];
            viewToMove.index = _heldIndex;
            [self.signs exchangeObjectAtIndex:_heldIndex withObjectAtIndex:frameIndex];
        }
         ];
        
        //update held index
        _heldIndex = frameIndex;
        self.heldSign.index = _heldIndex;
    } 
}

- (int)frameIndexForTileIndex:(int)tileIndex {
    for (int i = 0; i < self.signFrames.count; ++i) {
        BlankSignView *bsv = [self.signs objectAtIndex:i];
        if (bsv.index == tileIndex) {
            return i;
        }
    }
    return 0;
}

-(int)indexOfClosestFrameToPoint:(CGPoint)point 
{
    int index = 0;
    float minDist = FLT_MAX;
    for (int i = 0; i < self.signFrames.count; ++i) {
        CGRect frame = [[self.signFrames objectAtIndex:i] CGRectValue];
        
        float dx = point.x - CGRectGetMidX(frame);
        
        float dist = (dx * dx);
        if (dist < minDist) {
            index = i;
            minDist = dist;
        }
    }
    return index;
}

- (void)scrollSigns {
    CGPoint co = self.scrollView.contentOffset;
    CGRect rect = CGRectMake(co.x + _speed*10, co.y, self.scrollView.frame.size.width, kSignHeight);
    [UIView animateWithDuration:kScrollAnimationLength 
                          delay:0.0 
                        options:UIViewAnimationOptionCurveLinear 
                     animations:^{
                         [self.scrollView scrollRectToVisible:rect animated:NO];
                     }completion:NULL]; 
}

-(void)startWigglingSigns
{
    for (BlankSignView *bsv in self.signs)
    {
        if (bsv != self.heldSign) {
            [bsv startWiggling];
        }
    }
}

-(void)stopWigglingSigns
{
    for (BlankSignView *bsv in self.signs)
    {
        [bsv stopWiggling];
    }
} 

@end
