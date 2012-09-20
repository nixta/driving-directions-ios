//
//  PopupView.m
//  TestPopup
//
//  Created by Scott Sirowy on 1/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PopupView.h"
#import "PopupFrontView.h"
#import "PopupBackView.h"

#define kPOPUP_COLOR ([UIColor colorWithRed:(200.0/255.0) green:(200.0/255.0) blue:(200.0/255.0) alpha:1.0])

@interface PopupView () 

@property (nonatomic, retain) PopupBackView     *backView;
@property (nonatomic, retain) PopupFrontView    *frontView;

@end

@implementation PopupView

@synthesize backView    = _backView;
@synthesize frontView   = _frontView;

-(void)dealloc
{
    self.frontView  = nil;
    self.backView   = nil;
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        CGRect newRect = CGRectZero;
        newRect.size = frame.size;
        PopupFrontView *fv = [[PopupFrontView alloc] initWithFrame:newRect 
                                               withReflectionSlope:1.7 
                                                         startingX:225 
                                                         useShadow:YES];
        
        self.frontView = fv;
        [fv release];
        
        PopupBackView *bv = [[PopupBackView alloc] initWithFrame:newRect 
                                             withReflectionSlope:1.7 
                                                       startingX:225 
                                                       useShadow:YES];
        
        self.backView = bv;
        [bv release];
        
        
        self.frontView.signColor = self.backView.signColor = kPOPUP_COLOR;
        
        [self addSubview:self.frontView];
        _frontIsVisible = YES;
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
        
        tapRecognizer.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tapRecognizer];
        [tapRecognizer release];
    }
    return self;
}


-(void)viewTapped:(UIGestureRecognizer *)tapRecognizer
{
    // setup the animation group
	[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.75];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(myTransitionDidStop:finished:context:)];
	
	// swap the views and transition
    if (_frontIsVisible ==YES ) {
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self cache:YES];
        [self.frontView removeFromSuperview];
        [self addSubview:self.backView];

    } else {
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self cache:YES];
        [self.backView removeFromSuperview];
        [self addSubview:self.frontView];
    }
	[UIView commitAnimations];
    
    _frontIsVisible = !_frontIsVisible;
}

- (void)myTransitionDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    NSLog(@"Finished!");
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
