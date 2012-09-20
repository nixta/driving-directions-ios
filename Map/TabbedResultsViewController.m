//
//  TabbedResultsViewController.m
//  Map
//
//  Created by Scott Sirowy on 9/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TabbedResultsViewController.h"

@interface TabbedResultsViewController () 

@property (nonatomic, retain) UIButton *tabButton;

-(void)tabButtonPressed:(id)sender;

-(void)openTabAnimated:(BOOL)animated;
-(void)closeTabAnimated:(BOOL)animated;
-(void)hideTabAnimated:(BOOL)animated;

-(void)changeState:(TabbedResultsState)state;

-(CGFloat)originForViewInState:(TabbedResultsState)state;

@end

@implementation TabbedResultsViewController

@synthesize tabButton = _tabButton;
@synthesize tabDelegate = _tabDelegate;

static CGFloat kButtonWidth = 90;
static CGFloat kButtonHeight = 30;
static CGFloat kToolbarHeight = 44;

-(id)initWithTabState:(TabbedResultsState)state
{
    self = [super initWithToolbar:NO];
    
    if(self)
    {
        _state = state;
    }
    
    return self;
}

-(id)initWithToolbar:(BOOL)showToolbar
{
    return [self initWithTabState:TabbedStateHidden];
}

-(void)dealloc
{
    self.tabButton = nil;
    
    [super dealloc];
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    //modify tableview height to account for main toolbar
    CGRect tvRect = self.tableView.frame;
    tvRect.size.height -= kToolbarHeight;
    self.tableView.frame = tvRect;
    
    //Add the tab into the new space
    [self.view addSubview:self.tabButton];
    
    //set the background of main view to clear so we can see map behind
    self.view.backgroundColor = [UIColor clearColor];
    
    //set frame based on initial state
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y = [self originForViewInState:_state];
    self.view.frame = viewFrame;
}

-(void)setTabState:(TabbedResultsState)state animated:(BOOL)animated
{
    if (state == TabbedStateHidden) {
        [self hideTabAnimated:animated];
    }
    else if(state == TabbedStateClosed)
    {
        [self closeTabAnimated:animated];
    }
    else
    {
        [self openTabAnimated:animated];
    }
}

-(void)tabButtonPressed:(id)sender
{
    if (_state == TabbedStateOpen) {
        [self closeTabAnimated:YES];
    }
    else
    {
        [self openTabAnimated:YES];
    }
}

-(UIButton *)tabButton
{
    if(_tabButton == nil)
    {
        UIButton *tb = [UIButton buttonWithType:UIButtonTypeCustom];
        [tb setImage:[UIImage imageNamed:@"PullDownTabA.png"] 
            forState:UIControlStateNormal];
        
        
        [tb addTarget:self 
               action:@selector(tabButtonPressed:) 
     forControlEvents:UIControlEventTouchUpInside];
        
        CGFloat yOrigin = self.tableView.frame.size.height;
        
        //if we start in an open state,  button is going to be flipped around and in 
        //a different frame
        if (_state == TabbedStateOpen) {
            yOrigin = self.tableView.frame.size.height - kButtonHeight;
            tb.transform = CGAffineTransformMakeScale(1, -1);
        }
        
        tb.frame = CGRectMake((self.view.frame.size.width - kButtonWidth)/2, yOrigin, kButtonWidth, kButtonHeight);

        self.tabButton = tb;
    }
    
    return _tabButton;
}

-(void)openTabAnimated:(BOOL)animated
{
    if (_state == TabbedStateOpen)
        return;
    
    
    if (self.highlightCurrentIndex) {
        [self.tableView reloadData];
    }
    
    //Calculate new frame for main view
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y = [self originForViewInState:TabbedStateOpen];
    
    //Calculate new frame for tab
    CGRect tabRect = self.tabButton.frame;
    tabRect.origin.y -= tabRect.size.height;
    
    if(!animated)
    {
        self.view.frame = viewFrame;
        self.tabButton.transform = CGAffineTransformMakeScale(1, -1);
        self.tabButton.frame = tabRect;
    }
    //animation block. Uses a completion block to perform a second
    //animation to animate the tab back into position, but flipped 
    //over
    else
    {
        [UIView animateWithDuration:0.9 
                         animations:^{
                             self.view.frame = viewFrame;
                         }
                         completion:^(BOOL finished)
         {
             self.tabButton.transform = CGAffineTransformMakeScale(1, -1);
             
             //move it back up
             [UIView animateWithDuration:.4 
                              animations:^{
                                  self.tabButton.frame = tabRect;
                              }
              ];
         }
         ];
    }
    
    //finally, set state
    [self changeState:TabbedStateOpen];
}

-(void)closeTabAnimated:(BOOL)animated
{
    if (_state == TabbedStateClosed)
        return;
    
    
    //Calculate new frame for main view
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y = [self originForViewInState:TabbedStateClosed];
    
    //Calculate new frame for tab
    CGRect tabRect = self.tabButton.frame;
    tabRect.origin.y += tabRect.size.height;
    
    if(!animated)
    {
        self.view.frame = viewFrame;
        self.tabButton.transform = CGAffineTransformIdentity;
        self.tabButton.frame = tabRect;
    }
    //animation block. Uses a completion block to perform a second
    //animation to animate the tab back into position, but flipped 
    //over
    else
    {
        [UIView animateWithDuration:0.9 
                         animations:^{
                             self.view.frame = viewFrame;
                         }
                         completion:^(BOOL finished)
         {
             self.tabButton.transform = CGAffineTransformIdentity;
             
             //move it back up
             [UIView animateWithDuration:.4 
                              animations:^{
                                  self.tabButton.frame = tabRect;
                              }
              ];
         }
         ];
    }
    
    //finally, set state
    [self changeState:TabbedStateClosed];
}

-(void)hideTabAnimated:(BOOL)animated
{
    if (_state == TabbedStateHidden)
        return;
    
    
    //Calculate new frame for main view
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y = [self originForViewInState:TabbedStateHidden];
    
    //Calculate new frame for tab
    CGRect tabRect = self.tabButton.frame;
    
    //only need to modify the frame of the tab if we are coming
    //from an open state
    if (_state == TabbedStateOpen) {
        tabRect.origin.y += tabRect.size.height;
    }
    
    if(!animated)
    {
        self.view.frame = viewFrame;
        
        //need to flip and modify frame of tab if coming from open
        if (_state == TabbedStateOpen) {
            self.tabButton.transform = CGAffineTransformMakeScale(1, -1);
            self.tabButton.frame = tabRect;
        }
        
        //finally, set state
        [self changeState:TabbedStateHidden];
    }
    //animation block. Uses a completion block to perform a second
    //animation to animate the tab back into position, but flipped 
    //over, but only if coming from an open state
    else
    {
        [UIView animateWithDuration:0.9 
                         animations:^{
                             self.view.frame = viewFrame;
                         }
                         completion:^(BOOL finished)
         {         
             if (_state == TabbedStateOpen) {
                 self.tabButton.transform = CGAffineTransformIdentity;
                 self.tabButton.frame = tabRect;
             }

             //finally, set state
             [self changeState:TabbedStateHidden];
         }
         ];
    }
}

//returns where the view should originate from (in the y)
//for each valid state
-(CGFloat)originForViewInState:(TabbedResultsState)state
{
    if (state == TabbedStateHidden) {
        return - (self.view.frame.size.height);
    }
    else if(state == TabbedStateClosed)
    {
        return kToolbarHeight - self.tableView.frame.size.height;
    }
    
    return kToolbarHeight;
}

-(void)changeState:(TabbedResultsState)state
{
    _state = state;
    
    if([self.tabDelegate respondsToSelector:@selector(tabbedResultsViewController:didChangeToState:)])
    {
        [self.tabDelegate tabbedResultsViewController:self didChangeToState:state];
    }
}

@end
