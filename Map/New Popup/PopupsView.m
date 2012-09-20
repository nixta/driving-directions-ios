//
//  PopupsView.m
//  TestPopup
//
//  Created by Scott Sirowy on 1/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PopupsView.h"
#import "PopupFrontView.h"
#import "PopupView.h"

#define kWidthOfBigSign 300.0

@interface PopupsView () 

-(void)loadScrollViewWithPage:(int)page;
-(UIView *)viewWithPopup:(NSString *)popup;
-(void)setupScrollView;

@end

@implementation PopupsView

@synthesize scrollView  = _scrollView;
@synthesize popupViews  = _popupViews;
@synthesize popupData   = _popupData;

-(void)dealloc
{
    self.scrollView = nil;
    self.popupViews = nil;
    self.popupData  = nil;
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        NSMutableArray *strings = [NSMutableArray arrayWithObjects:@"Scott", @"Kyle", @"Christa", nil];
        self.popupData = strings;
    
        self.popupViews = [NSMutableArray arrayWithCapacity:self.popupData.count];
        
        for (unsigned i = 0; i < self.popupData.count; i++)
        {
            [self.popupViews addObject:[NSNull null]];
        }
    }
    return self;
}

-(void)layoutSubviews
{      
    if (self.scrollView.superview == nil) {
        [self setupScrollView];
    }
    
    self.backgroundColor = [UIColor clearColor];
}

#pragma mark -
#pragma mark Scrolling
-(void)loadScrollViewWithPage:(int)page
{
    if (page < 0)
        return;
    if (page >= self.popupData.count)
        return;
    
    // replace the placeholder if necessary
    UIView *view = [self.popupViews objectAtIndex:page];
    if ((NSNull *)view == [NSNull null])
    {
        NSString *popupString = [self.popupData objectAtIndex:page];
        view = [self viewWithPopup:popupString];
        
        //replace in views array
        [self.popupViews replaceObjectAtIndex:page withObject:view];
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

-(void)setupScrollView
{
    if(self.scrollView.superview == nil)
    {
        [self addSubview:self.scrollView];
        
        CGFloat width = self.popupData.count*self.sizeOfSign;
        self.scrollView.contentSize = CGSizeMake(width, self.frame.size.height);
        
        [self loadScrollViewWithPage:0];
        [self loadScrollViewWithPage:1];
    }
}

#pragma mark -
#pragma mark UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{	
    // Calculate which page is visible 
	CGFloat pageWidth = self.scrollView.frame.size.width;
	_currentPage = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadScrollViewWithPage:_currentPage-1];
    [self loadScrollViewWithPage:_currentPage];
    [self loadScrollViewWithPage:_currentPage+1];
}

-(UIView *)viewWithPopup:(NSString *)popup
{    
    PopupView *pv = [[PopupView alloc] initWithFrame:self.scrollView.frame];
    return [pv autorelease];
}

#pragma mark -
#pragma mark Lazy Loads
-(UIScrollView *)scrollView
{
    if(_scrollView == nil)
    {
        UIScrollView *sv = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 0, self.sizeOfSign, self.frame.size.height)];
        
        //Configure scroll view   
        sv.pagingEnabled = YES;
        sv.bounces = YES;
        
        sv.showsVerticalScrollIndicator = NO;
        sv.showsHorizontalScrollIndicator = NO;
        sv.delegate = self;
        sv.clipsToBounds = NO;
        
        self.scrollView = sv;
        [sv release];
    }
    return _scrollView;
}

/*Overridden Implementation */
-(CGFloat)sizeOfSign
{
    return (kWidthOfBigSign);
}

@end
