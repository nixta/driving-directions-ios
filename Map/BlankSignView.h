//
//  BlankSignView.h
//  StreetSignTest
//
//  Created by Scott Sirowy on 11/17/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

/*
 A view that takes on the appearance of a street sign.
 */

#import <UIKit/UIKit.h>

@interface BlankSignView : UIView
{
    CGFloat     _reflectionSlope;
    CGFloat     _xShadow;
    CGFloat     _xIntercept;
    NSUInteger  _index;
    BOOL        _useShadow;
    BOOL        _editable;
}

@property (nonatomic, assign) CGFloat       reflectionSlope;
@property (nonatomic, assign) CGFloat       xShadow;
@property (nonatomic, assign) CGFloat       xIntercept;
@property (nonatomic, assign) NSUInteger    index;
@property (nonatomic, assign) BOOL          editable;

-(id)initWithFrame:(CGRect)frame withReflectionSlope:(CGFloat)slope startingX:(CGFloat)x useShadow:(BOOL)useShadow;
-(id)initWithFrame:(CGRect)frame withReflectionSlope:(CGFloat)slope startingX:(CGFloat)x useShadow:(BOOL)useShadow editable:(BOOL)editable;

/*Animation Methods */
-(void)startWiggling;
-(void)stopWiggling;
-(void)appearDraggable;
-(void)appearNormal;

-(CGRect)calculateContentRect:(CGRect)frame;

+(CGFloat)radius;

@end
