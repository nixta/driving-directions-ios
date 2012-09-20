//
//  PopupView.h
//  TestPopup
//
//  Created by Scott Sirowy on 1/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/*
 Container view for front and backsides of popup
 */

#import <UIKit/UIKit.h>

@class PopupFrontView;
@class PopupBackView;

@interface PopupView : UIView
{
    PopupFrontView  *_frontView;
    PopupBackView   *_backView;
    
    BOOL _frontIsVisible;
}

@end
