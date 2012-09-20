//
//  BlankSignView.m
//  StreetSignTest
//
//  Created by Scott Sirowy on 11/17/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BlankSignView.h"
#import <QuartzCore/QuartzCore.h>

//#define USE_STREET_SIGN_COLOR 1

@interface BlankSignView () 

- (CAAnimation *)wiggleRotationAnimation;
- (CAAnimation *)wiggleTranslationYAnimation;

@end

@implementation BlankSignView

@synthesize reflectionSlope = _reflectionSlope;
@synthesize xShadow         = _xShadow;
@synthesize xIntercept      = _xIntercept;
@synthesize index           = _index;
@synthesize editable        = _editable;


- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame withReflectionSlope:0 startingX:0 useShadow:YES editable:YES];
}

-(id)initWithFrame:(CGRect)frame withReflectionSlope:(CGFloat)slope startingX:(CGFloat)x useShadow:(BOOL)useShadow
{
    return [self initWithFrame:frame withReflectionSlope:slope startingX:x useShadow:useShadow editable:YES];
}

//default initializer
-(id)initWithFrame:(CGRect)frame withReflectionSlope:(CGFloat)slope startingX:(CGFloat)x useShadow:(BOOL)useShadow editable:(BOOL)editable
{
    self = [super initWithFrame:frame];
    if (self) {
        self.reflectionSlope = slope;
        self.xShadow = x;
        self.xIntercept = NAN;
        _useShadow = useShadow;
        
        //editable in the sense that it can be moved around when shown with other
        //signs
        self.editable = editable;
    }
    return self;
}

-(void)setEditable:(BOOL)editable
{
    if(editable == _editable)
        return;
    
    _editable = editable;
    [self setNeedsDisplay];
}

-(UIColor *)streetSignColor
{
    //return [UIColor colorWithRed:34.0/255.0 green:139.0/255.0 blue:94.0/255.0 alpha:1.0];
    
    UIColor *streetSignColor = self.editable ? [UIColor blackColor] : [[UIColor darkGrayColor] colorWithAlphaComponent:.70];
    return streetSignColor;
}

- (CGPathRef) newPathForRoundedRect:(CGRect)rect radius:(CGFloat)radius
{    
    //
    //Code for roundedRect found on StackOverflow
    //
    
	CGMutablePathRef retPath = CGPathCreateMutable();
    
	CGRect innerRect = CGRectInset(rect, radius, radius);
    
	CGFloat inside_right = innerRect.origin.x + innerRect.size.width;
	CGFloat outside_right = rect.origin.x + rect.size.width;
	CGFloat inside_bottom = innerRect.origin.y + innerRect.size.height;
	CGFloat outside_bottom = rect.origin.y + rect.size.height;
    
	CGFloat inside_top = innerRect.origin.y;
	CGFloat outside_top = rect.origin.y;
	CGFloat outside_left = rect.origin.x;
    
	CGPathMoveToPoint(retPath, NULL, innerRect.origin.x, outside_top);
    
	CGPathAddLineToPoint(retPath, NULL, inside_right, outside_top);
	CGPathAddArcToPoint(retPath, NULL, outside_right, outside_top, outside_right, inside_top, radius);
	CGPathAddLineToPoint(retPath, NULL, outside_right, inside_bottom);
	CGPathAddArcToPoint(retPath, NULL,  outside_right, outside_bottom, inside_right, outside_bottom, radius);
    
	CGPathAddLineToPoint(retPath, NULL, innerRect.origin.x, outside_bottom);
	CGPathAddArcToPoint(retPath, NULL,  outside_left, outside_bottom, outside_left, inside_bottom, radius);
	CGPathAddLineToPoint(retPath, NULL, outside_left, inside_top);
	CGPathAddArcToPoint(retPath, NULL,  outside_left, outside_top, innerRect.origin.x, outside_top, radius);
    
	CGPathCloseSubpath(retPath);
    
	return retPath;
}

- (CGPathRef) newPathForLightReflectionRect:(CGRect)rect
{    
	CGMutablePathRef retPath = CGPathCreateMutable();
        
    CGPathMoveToPoint(retPath, NULL, self.xShadow, rect.origin.y);      //starting point
    
    //need to calculate if shadow crosses on y or x intercept
    
    //y = mx +b  calculating b
    CGFloat bIntercept = rect.size.height - self.xShadow*self.reflectionSlope;
    
    //hits y intercept
    if (bIntercept > 0.0) {
        CGPathAddLineToPoint(retPath, NULL, rect.origin.x, rect.size.height - bIntercept);   //top left
        CGPathAddLineToPoint(retPath, NULL, rect.origin.x, rect.size.height);   //bottom left
    }
    else
    {
        //need x intercept now
        self.xIntercept = -bIntercept/self.reflectionSlope;
        CGPathAddLineToPoint(retPath, NULL, self.xIntercept, rect.size.height);   //bottom
    }
    
    CGPathAddLineToPoint(retPath, NULL, rect.size.width, rect.size.height);   //bottom right corner
	CGPathAddLineToPoint(retPath, NULL, rect.size.width, rect.origin.y);  //top 
    
	CGPathCloseSubpath(retPath);
    
	return retPath;
}

- (void)drawRect:(CGRect)rect
{
    CGFloat radius = [BlankSignView radius];
    
    // get the contect
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect contentRect = [self calculateContentRect:rect];
    
    //for the shadow, save the state then draw the shadow
    CGContextSaveGState(context);
    
    CGPathRef roundedRectPath = [self newPathForRoundedRect:contentRect radius:radius];
    CGContextAddPath(context, roundedRectPath);
    
    //create shadow for path
    if (_useShadow) 
        CGContextSetShadow(context, CGSizeMake(4, 5), 7);
    
    CGContextSetStrokeColorWithColor(context, [[self streetSignColor] CGColor]);
    CGContextSetLineWidth(context, 5.0);
    CGContextSetFillColorWithColor(context, [[self streetSignColor] CGColor]);
    
    CGContextDrawPath(context, kCGPathFillStroke);
    
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, 1.50);
    
    if (!self.editable) {
        CGContextSetLineWidth(context, 3.50);
        CGFloat dash1[] = {4.0, 4.0};
        CGContextSetLineDash(context, 0.0, dash1, 2);
    }
    
    CGContextAddPath(context, roundedRectPath);
    CGContextDrawPath(context, kCGPathStroke);
    
    CGPathRef lightPath = [self newPathForLightReflectionRect:rect];
    
    //draw some "lighting" on top of the sign
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] colorWithAlphaComponent:0.12].CGColor);
    CGContextAddPath(context, lightPath);
    CGContextDrawPath(context, kCGPathFill); 
    
    CGPathRelease(lightPath); 
    CGPathRelease(roundedRectPath);
    
    CGContextRestoreGState(context);
}

#pragma mark -
#pragma mark Draggable animation

- (void)appearDraggable {
    
    if (!self.editable) 
        return;
    
    self.layer.opacity = 0.6f;
    [self.layer setValue:[NSNumber numberWithFloat:1.2f] forKeyPath:@"transform.scale"];
}


- (void)appearNormal {
    
    if (!self.editable) 
        return;
    
    self.layer.opacity = 1.0f;
    [self.layer setValue:[NSNumber numberWithFloat:1.0f] forKeyPath:@"transform.scale"];
}

- (void)startWiggling {
    if (!self.editable) 
        return;
    
    CAAnimation *rotationAnimation = [self wiggleRotationAnimation];
    [self.layer addAnimation:rotationAnimation forKey:@"wiggleRotation"];
    
    CAAnimation *translationYAnimation = [self wiggleTranslationYAnimation];
    [self.layer addAnimation:translationYAnimation forKey:@"wiggleTranslationY"];
}

- (void)stopWiggling {
    if (!self.editable) 
        return;
    
    [self.layer removeAnimationForKey:@"wiggleRotation"];
    [self.layer removeAnimationForKey:@"wiggleTranslationY"];
    
    //NSLog(@"Sign %d stopped wiggling", self.index);
}

- (CAAnimation *)wiggleRotationAnimation {
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
    anim.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:-0.05f],
                   [NSNumber numberWithFloat:0.05f],
                   nil];
    anim.duration = 0.09f + ((self.index % 11) * 0.01f);
    anim.autoreverses = YES;
    anim.repeatCount = HUGE_VALF;
    return anim;
}


- (CAAnimation *)wiggleTranslationYAnimation {
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];
    anim.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:-1.0f],
                   [NSNumber numberWithFloat:1.0f],
                   nil];
    anim.duration = 0.07f + ((self.index % 10) * 0.01f);
    anim.autoreverses = YES;
    anim.repeatCount = HUGE_VALF;
    anim.additive = YES;
    return anim;
}

-(CGRect)calculateContentRect:(CGRect)frame
{
    //actual rect used for content... Slightly offset of rect parameter to account for shadow
    if(_useShadow)
       return CGRectMake(CGRectGetMinX(frame)+5, CGRectGetMinY(frame)+5, CGRectGetWidth(frame)-15, CGRectGetHeight(frame)-15);
    
    
    return CGRectMake(CGRectGetMinX(frame)+3, CGRectGetMinY(frame)+3, CGRectGetWidth(frame)-6, CGRectGetHeight(frame)-6);
}

#pragma mark -
#pragma mark Class Methods
//Other classes might be interested in the sign's corner radius
+(CGFloat)radius
{
    return 10.0;
}

@end
