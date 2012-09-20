//
//  OverlayViewController.m
//  Map
//
//  Created by Scott Sirowy on 9/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OverlayViewController.h"
#import "Direction.h"
//#import "OverlayView.h"
#import "DrawableList.h"
#import "DrawableCollection.h"
#import "StreetSignView.h"

@interface OverlayViewController () 

-(void)loadScrollViewWithPage:(int)page;
-(void)setupScrollView;

-(void)manuallyScrollToPage:(NSUInteger)page;
-(void)resultChangedTo:(NSUInteger)index;

/*Overlay is going to be able to animate up. This is the view that
 shoudl correspond with the animation of the overlay being animated
 */
@property (nonatomic, assign) UIView                    *viewToAnimate;
@property (nonatomic, retain) NSMutableArray            *views;
@property (nonatomic, retain) DrawableCollection        *collection;

@end

@implementation OverlayViewController

@synthesize scrollView  = _scrollView;

@synthesize viewToAnimate = _viewToAnimate;

@synthesize delegate = _delegate;

@synthesize views = _views;

@synthesize collection= _collection;

-(void)dealloc
{
    for(int i = 0; i < self.views.count; i++)
    {
        UIView *view = [self.views objectAtIndex:i];
        if ((NSNull *)view != [NSNull null])
        {
            [view removeFromSuperview];
        }
    }
    
    self.views = nil;
    self.scrollView = nil;
    self.viewToAnimate = nil;
    
    self.collection = nil;
    
    [super dealloc];
}

/*default initializer */
-(id)initWithFrame:(CGRect)initialFrame withAdjoiningView:(UIView *)view withDrawableCollection:(DrawableCollection *)collection
{
    self = [super initWithNibName:@"OverlayViewController" bundle:nil];
    
    if(self)
    {
        _initialFrame = initialFrame;
        self.viewToAnimate = view;
        self.collection = collection;
    }
    
    return self;
}

-(id)initWithFrame:(CGRect)initialFrame withAdjoiningView:(UIView *)view withDrawableList:(DrawableList *)list
{
    DrawableCollection *newCollection = [[[DrawableCollection alloc] initWithList:list] autorelease];
    return [self initWithFrame:initialFrame withAdjoiningView:view withDrawableCollection:newCollection];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self initWithFrame:CGRectZero withAdjoiningView:nil withDrawableCollection:nil];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.frame = _initialFrame;
        
    [self setupScrollView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Scroll View Setup

-(void)setupScrollView
{
    NSUInteger numberOfItems = [self.collection totalNumberOfItems];
    
    self.views = [NSMutableArray arrayWithCapacity:numberOfItems];
    for (unsigned i = 0; i < numberOfItems; i++)
    {
        [self.views addObject:[NSNull null]];
    }
        
    //Configure scroll view   
    self.scrollView.pagingEnabled = YES;
    self.scrollView.bounces = YES;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width*numberOfItems, self.scrollView.frame.size.height);
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.delegate = self;
    self.scrollView.clipsToBounds = NO;
        
    [self loadScrollViewWithPage:-1];
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
}

-(void)loadScrollViewWithPage:(int)page
{
    if (page < 0)
        return;
    if (page >= [self.collection totalNumberOfItems])
        return;
    
    // replace the placeholder if necessary
    UIView *view = [self.views objectAtIndex:page];
    if ((NSNull *)view == [NSNull null])
    {        
        view = [self viewWithItem:[self.collection itemAtIndex:page]];
        [self.views replaceObjectAtIndex:page withObject:view];
    }
    
    // add the controller's view to the scroll view
    if (view.superview == nil)
    {
		CGRect viewFrame = view.frame;
		viewFrame.origin.x = self.scrollView.frame.size.width * page; 
		view.frame = viewFrame;
        
        [self.scrollView addSubview:view];
    }
}

/*Default implementation. Returns a basic view to show some information about the particular
 item.
 
 Could be overridden to provide a more custom view!
 */
-(UIView *)viewWithItem:(id<TableViewDrawable>)item
{
    OverlayView *overlayView = [[[OverlayView alloc] initWithFrame:self.scrollView.frame 
                                                          withItem:item] autorelease];
    
    return overlayView;
}

#pragma mark -
#pragma mark Public Methods
-(void)setExpanded:(BOOL)expanded animated:(BOOL)animated
{
    if (_expanded == expanded)
        return;
    
	_expanded = expanded;
	
	if (_expanded){
        
        CGRect myViewRect = self.view.frame;
        myViewRect.origin.y -= myViewRect.size.height;
        
        CGRect adjoiningRect = self.viewToAnimate.frame;
        //adjoiningRect.size.height -= myViewRect.size.height;
        adjoiningRect.origin.y -= myViewRect.size.height;
        
        if(animated)
        {
            [UIView animateWithDuration:0.5 
                             animations:^{
                                 self.view.frame = myViewRect;
                                 self.viewToAnimate.frame = adjoiningRect;
                 
                            }
             completion:^(BOOL finished)
             {
                 if ([self.delegate respondsToSelector:@selector(overlayViewControllerDidExpand:)]) {
                     [self.delegate overlayViewControllerDidExpand:self];
                 }
             }
             ];
        }
        else
        {
            self.view.frame = myViewRect;
            self.viewToAnimate.frame = adjoiningRect;
            
            if ([self.delegate respondsToSelector:@selector(overlayViewControllerDidExpand:)]) {
                [self.delegate overlayViewControllerDidExpand:self];
            }
        }
	}
	else {
        CGRect myViewRect = self.view.frame;
        myViewRect.origin.y += myViewRect.size.height;
        
        CGRect adjoiningRect = self.viewToAnimate.frame;
        //adjoiningRect.size.height += myViewRect.size.height;
        adjoiningRect.origin.y += myViewRect.size.height;
        
        if(animated)
        {
            [UIView animateWithDuration:0.5 
                             animations:^{
                                 self.view.frame = myViewRect;
                                 self.viewToAnimate.frame = adjoiningRect;
                                 
                             }
                             completion:^(BOOL finished)
             {
                 if ([self.delegate respondsToSelector:@selector(overlayViewControllerDidHide:)]) {
                     [self.delegate overlayViewControllerDidHide:self];
                 }
             }
             ];
        }
        else
        {
            self.view.frame = myViewRect;
            self.viewToAnimate.frame = adjoiningRect;
            
            if ([self.delegate respondsToSelector:@selector(overlayViewControllerDidHide:)]) {
                [self.delegate overlayViewControllerDidHide:self];
            }
        }	
    }
}

/*Manually change to a different result */
-(void)changeToResult:(id<TableViewDrawable>)result
{
    if ([self.collection itemExists:result]) {
        NSUInteger newPage = [self.collection indexOfItem:result];
        
        [self manuallyScrollToPage:newPage];
        [self resultChangedTo:newPage];
    }
}

#pragma mark -
#pragma mark Button Interaction
-(IBAction)leftArrowButtonPressed:(id)sender
{
    [self manuallyScrollToPage:_currentPage -1];
    [self resultChangedTo:_currentPage - 1];
}

-(IBAction)rightArrowButtonPressed:(id)sender
{
    [self manuallyScrollToPage:_currentPage + 1];
    [self resultChangedTo:_currentPage + 1];
}

#pragma mark -
#pragma mark UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{	
    // Calculate which page is visible 
	CGFloat pageWidth = self.scrollView.frame.size.width;
	_currentPage = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    [self loadScrollViewWithPage:_currentPage-1];
    [self loadScrollViewWithPage:_currentPage];
    [self loadScrollViewWithPage:_currentPage+1];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self resultChangedTo:_currentPage];
}


#pragma mark -
#pragma mark Result changed
-(void)manuallyScrollToPage:(NSUInteger)page
{
    if (page >= [self.collection totalNumberOfItems])
        return;

    CGFloat svWidth = self.scrollView.frame.size.width;
    CGFloat svHeight = self.scrollView.frame.size.height;
    
    [self.scrollView scrollRectToVisible:CGRectMake(page*svWidth, 0, svWidth, svHeight) animated:YES];
}

-(void)resultChangedTo:(NSUInteger)index
{
    //update list index
    self.collection.currentIndex = index;
    
    //inform anyone who is interested
    if([self.delegate respondsToSelector:@selector(overlayViewController:didChangeToOrTapOnResult:)])
    {
        id<NamedGeometry> ng = nil;
        id result = [self.collection itemAtIndex:index];
        if ([result conformsToProtocol:@protocol(NamedGeometry)]) {
            ng = (id<NamedGeometry>)result;
        }
        
        [self.delegate overlayViewController:self 
                    didChangeToOrTapOnResult:ng];
    }
}

@end

@implementation StreetSignOverlayViewController

-(UIView *)viewWithItem:(id<TableViewDrawable>)item
{
    Direction *direction = (Direction *)item;
    
    StreetSignView *ssv = [[[StreetSignView alloc] initWithFrame:self.scrollView.frame 
                                                   withDirection:direction] autorelease];
    
    ssv.backgroundColor = [UIColor clearColor];
    
    return ssv;
}

@end
