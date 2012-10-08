//
//  AdvancedToolbar.m
//  AdvancedToolbar
//
//  Created by Scott Sirowy on 12/4/11.
//  Copyright (c) 2011 ESRI. All rights reserved.
//

#import "ExtendableToolbar.h"

@interface ExtendableToolbar () 

@property (nonatomic, strong) UIView        *contentView;
@property (nonatomic, strong) UIToolbar     *toolbar;

@end

@implementation ExtendableToolbar

#define kSizeOfToolbar 44
#define kAnimationDuration .4
#define kSizeOfArrow 12

@synthesize toolbar                 = _toolbar;
@synthesize toolsView               = _toolsView;
@synthesize supplementalToolsView   = _supplementalToolsView;
@synthesize selectedButtonArrow     = _selectedButtonArrow;

@synthesize contentView = _contentView;


//The advanced toolbar allows a user to show extended tools from a bar button.  There are two options for the toolbar
//that can be configured at initialization. One is that the extended tools show below the toolbar and the toolbar
//stays in a fixed location. The other option (showBelowToolbar = NO), the toolbar itself moves down to reveal a set of
//extended tools beneath the toolbar
-(id)initWithFrame:(CGRect)frame showToolsBelowToolbar:(BOOL)showBelowToolbar
{
    frame.size.height = 2*kSizeOfToolbar;
    
    self = [super initWithFrame:frame];
    if (self) {
        
        _showToolsBelow = showBelowToolbar;
        
        self.backgroundColor = [UIColor clearColor];
        
        UIView *aToolView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, kSizeOfToolbar)];
        aToolView.backgroundColor = [UIColor clearColor];
        
        self.toolsView = aToolView;
        
        UIToolbar *tb = [[UIToolbar alloc] initWithFrame:self.toolsView.frame];
        tb.barStyle = UIBarStyleBlackOpaque;
        tb.tintColor = [UIColor blackColor];
        self.toolbar = tb;
        
        [self.toolsView addSubview:self.toolbar];
        
        _showingTools = NO;
        
        UIView *cv = [[UIView alloc] initWithFrame:self.toolsView.frame];
        cv.backgroundColor = [UIColor clearColor];
        
        self.contentView = cv;
        
        CGFloat yOrigin = _showToolsBelow ? (kSizeOfToolbar-kSizeOfArrow-1) : (kSizeOfToolbar-kSizeOfArrow);
        
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(10, yOrigin, 30, kSizeOfArrow)];
        
        iv.image = _showToolsBelow ? [UIImage imageNamed:@"selected.png"] : [UIImage imageNamed:@"upselected.png"];
        
        self.selectedButtonArrow = iv;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame showToolsBelowToolbar:YES];
}

-(void)layoutSubviews
{
    if(self.contentView.superview == nil)
    {
        [self addSubview:self.contentView];
    }
    
    if(self.selectedButtonArrow.superview == nil)
    {
        [self addSubview:self.selectedButtonArrow];
    }
    
    if (self.toolsView.superview == nil) {
        [self addSubview:self.toolsView];
    }
}

-(void)showTools:(BOOL)show fromRect:(CGRect)rect animated:(BOOL)animated
{   
    CGRect selectedRect = self.selectedButtonArrow.frame;
    
    UIView *viewToMove = _showToolsBelow ? self.contentView : self.toolsView;
    CGRect cvRect = viewToMove.frame;
    
    //if showing tools AND we are already showing, only animate arrow to right or left
    if (_showingTools && show) {
        selectedRect.origin.x = rect.origin.x;
    }
    else if(_showingTools && !show)
    {
        selectedRect.origin.y -= _showToolsBelow ? kSizeOfArrow : 2;
        cvRect.origin.y -= kSizeOfToolbar;
        
        [self.selectedButtonArrow  removeFromSuperview];
        [self insertSubview:self.selectedButtonArrow belowSubview:self.toolsView];
    }
    else if(!_showingTools && show)
    {
        //put arrow in correct place before animation
        if (!CGRectEqualToRect(rect, CGRectZero)) {
            selectedRect.origin.x = rect.origin.x;
        }
    
        self.selectedButtonArrow.frame = selectedRect;
        
        selectedRect.origin.y += _showToolsBelow ? kSizeOfArrow : 2;
        cvRect.origin.y += kSizeOfToolbar;
    }
    //!_showingTools && !show
    else
    {
        return;
    }
        
    if(animated)
    {
        [UIView animateWithDuration:kAnimationDuration animations:^
         {
             viewToMove.frame = cvRect;
             self.selectedButtonArrow.frame = selectedRect;
         } completion:^(BOOL completed)
         {
             if(show)
             {
                 [self.selectedButtonArrow  removeFromSuperview];
                 [self insertSubview:self.selectedButtonArrow aboveSubview:self.toolsView];
             }
         }
         ];
    }
    else
    {
        viewToMove.frame = cvRect;
        self.selectedButtonArrow.frame = selectedRect;
        
        if(show)
        {
            [self.selectedButtonArrow  removeFromSuperview];
            [self insertSubview:self.selectedButtonArrow aboveSubview:self.toolsView];
        }
    }
    
    _showingTools = show;
}

#pragma mark -
#pragma mark Custom Setter
-(void)setSupplementalToolsView:(UIView *)supplementalToolsView
{
	if (_supplementalToolsView){
		[_supplementalToolsView removeFromSuperview];
	}
	
	_supplementalToolsView = supplementalToolsView;
	
	_supplementalToolsView.alpha = 1;
    
	[self.contentView addSubview:_supplementalToolsView]; 
}

//pass through to items on actual toolbar
-(void)setItems:(NSArray *)items
{
    self.toolbar.items = items;
}

#pragma mark -
#pragma mark Custom Getters
-(NSArray *)items
{
    return self.toolbar.items;
}

#pragma mark -
#pragma mark Class Methods
+(CGFloat)heightOfSupplementalToolsView
{
    return kSizeOfToolbar;
}

@end
