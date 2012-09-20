//
//  PassThroughView.m
//  Map
//
//  Created by Scott Sirowy on 12/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

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
