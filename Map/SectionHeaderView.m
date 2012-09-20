
/*
     File: SectionHeaderView.m
 Abstract: A view to display a section header, and support opening and closing a section.
 
  Version: 1.1
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2010 Apple Inc. All Rights Reserved.
 
 */

#import "SectionHeaderView.h"
#import "UIColor+Additions.h"
#import <QuartzCore/QuartzCore.h>

@interface SectionHeaderView () 

-(void)switchToggled:(id)sender;

@end

@implementation SectionHeaderView


@synthesize titleLabel = _titleLabel;
@synthesize disclosureButton = _disclosureButton;
@synthesize aSwitch = _aSwitch;
@synthesize delegate = _delegate;
@synthesize section = _section;

-(id)initWithFrame:(CGRect)frame title:(NSString*)title section:(NSInteger)sectionNumber delegate:(id <SectionHeaderViewDelegate>)aDelegate {
    
    self = [super initWithFrame:frame];
    
    if (self != nil) {
        
        // Set up the tap gesture recognizer.
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleOpen:)];
        [self addGestureRecognizer:tapGesture];
        [tapGesture release];

        _delegate = aDelegate;        
        self.userInteractionEnabled = YES;
        
        //Create and configure switch
        CGFloat switchWidth = 94;  
        CGFloat switchHeight = 27;
        CGFloat rightMargin = 10;
        CGFloat switchXOrigin = frame.size.width - (switchWidth + rightMargin);
        
        CGFloat toggleButtonWidthHeight = 35.0;
        CGFloat titleLabelXOrigin = toggleButtonWidthHeight;
        CGFloat titleLabelWidth = switchXOrigin - titleLabelXOrigin;
        
        // Create and configure the title label.
        _section = sectionNumber;
        CGRect titleLabelFrame = self.bounds;
        titleLabelFrame.origin.x = titleLabelXOrigin;
        titleLabelFrame.size.width = titleLabelWidth;
        CGRectInset(titleLabelFrame, 0.0, 5.0);
        
        CGSize constrainedSize = [title sizeWithFont:[UIFont boldSystemFontOfSize:16.0] 
                                  constrainedToSize:CGSizeMake(titleLabelWidth, 20000.0f) 
                                      lineBreakMode:UILineBreakModeWordWrap];
        
        if (constrainedSize.height > titleLabelFrame.size.height) {
            titleLabelFrame.size.height = constrainedSize.height;
            
            CGRect myRect = self.frame;
            myRect.size.height = constrainedSize.height;
            self.frame = myRect;
        }
        
        _titleLabel = [[UILabel alloc] initWithFrame:titleLabelFrame];
        _titleLabel.numberOfLines = 0;
        _titleLabel.text = title;
        _titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_titleLabel];
        
        
        // Create and configure the disclosure button.
        _disclosureButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        _disclosureButton.frame = CGRectMake(0.0, (self.frame.size.height - toggleButtonWidthHeight)/2, toggleButtonWidthHeight, toggleButtonWidthHeight);
        [_disclosureButton setImage:[UIImage imageNamed:@"MaxMinLayerTriangle.png"] forState:UIControlStateNormal];
        [_disclosureButton setImage:[UIImage imageNamed:@"MaxMinLayerTriangle-Open.png"] forState:UIControlStateSelected];
        [_disclosureButton addTarget:self action:@selector(toggleOpen:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_disclosureButton];
        
        self.aSwitch = [[[UISwitch alloc] initWithFrame:CGRectMake(switchXOrigin, (self.frame.size.height - switchHeight)/2, switchWidth, switchHeight)] autorelease];
        self.aSwitch.on = YES;
        [self.aSwitch addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.aSwitch];
        
        self.backgroundColor = [UIColor offWhiteColor];
        
    }
    
    return self;
}


-(IBAction)toggleOpen:(id)sender {
    
    [self toggleOpenWithUserAction:YES];
}


-(void)toggleOpenWithUserAction:(BOOL)userAction {
    
    // Toggle the disclosure button state.
    self.disclosureButton.selected = !_disclosureButton.selected;
    
    // If this was a user action, send the delegate the appropriate message.
    if (userAction) {
        if (self.disclosureButton.selected) {
            if ([self.delegate respondsToSelector:@selector(sectionHeaderView:sectionOpened:)]) {
                [self.delegate sectionHeaderView:self sectionOpened:self.section];
            }
        }
        else {
            if ([self.delegate respondsToSelector:@selector(sectionHeaderView:sectionClosed:)]) {
                [self.delegate sectionHeaderView:self sectionClosed:self.section];
            }
        }
    }
}


-(void)switchToggled:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(sectionHeaderView:toggledUISwitch:)]) {
        [self.delegate sectionHeaderView:self toggledUISwitch:self.aSwitch];
    }
}


- (void)dealloc {
    
    self.titleLabel = nil;
    self.disclosureButton = nil;
    self.aSwitch = nil;
    
    [super dealloc];
}


@end
