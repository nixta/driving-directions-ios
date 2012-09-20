//
//  PopupsView.h
//  TestPopup
//
//  Created by Scott Sirowy on 1/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopupsView : UIView <UIScrollViewDelegate>
{
    UIScrollView    *_scrollView;
    NSUInteger      _currentPage;
    
    NSMutableArray  *_popupViews;
    NSArray         *_popupData;
}

@property (nonatomic, retain) UIScrollView      *scrollView;
@property (nonatomic, retain) NSMutableArray    *popupViews;
@property (nonatomic, retain) NSArray           *popupData;

-(CGFloat)sizeOfSign;

@end
