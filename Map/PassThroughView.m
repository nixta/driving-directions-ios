//
//  PassThroughView.m
//  Map
//
//  Created by Scott Sirowy on 12/15/11.
/*
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

#import "PassThroughView.h"

@implementation PassThroughView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

//allows to pass through touches only when needed. Limiting touches to subviews whose alpha > 0
-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    for (UIView *view in self.subviews)
    {
        //if([view pointInside:[self convertPoint:point toView:view] withEvent:event] && view.alpha != 0){
        if([view pointInside:[self convertPoint:point toView:view] withEvent:event]){
            return YES;
        }
    }
    
    return NO;
}

@end
