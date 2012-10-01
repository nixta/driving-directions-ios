//
//  AdvancedToolbar.h
//  AdvancedToolbar
//
//  Created by Scott Sirowy on 12/4/11.
//  Copyright (c) 2011 ESRI. All rights reserved.
//

/*
 Extendable Toolbar wraps a UIToolbar
 and allows for a small drop down overlay to show beneath the selected button.
 The user of this control is still required to pass a message to the control
 to say when to show/hide the drop down menu as the user will likely create
 a method to hook into the UIBarbutton and needs to instruct the ExtendedToolbar
 to animate
 
 How to get the CGRect of a button on the toolbar? (UIBarButtonItem does not extend UIView,
 so there is no concept of a frame on the UIBarButton) Instead of passing the typical
 selector template buttonPressed:(id)sender to the button,   pass in the extended selector
 buttonPressed:(id)sender event:(UIEvent *)event. From the event, it is easy to
 get the viewRect for the touched control
 */

#import <UIKit/UIKit.h>
#import "PassThroughView.h"

@interface ExtendableToolbar : PassThroughView
{
    UIToolbar   *_toolbar;
    UIView      *_contentView;
    UIView      *_toolsView;
    UIView      *_supplementalToolsView;
    UIImageView *_selectedButtonArrow;
    BOOL        _showingTools;
    BOOL        _showToolsBelow;
}

//Wrapper for the items array on the private UIToolbar
@property (nonatomic, strong) NSArray           *items;

@property (nonatomic, strong) UIView            *toolsView;
@property (nonatomic, strong) UIView            *supplementalToolsView;
@property (nonatomic, strong) UIImageView       *selectedButtonArrow;

-(id)initWithFrame:(CGRect)frame showToolsBelowToolbar:(BOOL)showBelowToolbar;

-(void)showTools:(BOOL)show fromRect:(CGRect)rect animated:(BOOL)animated;
+(CGFloat)heightOfSupplementalToolsView;

@end
