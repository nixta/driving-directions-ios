//
//  PopupView.m
//  TestPopup
//
//  Created by Scott Sirowy on 1/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PopupFrontView.h"

@implementation PopupFrontView

@synthesize tableview = _tableview;

-(void)dealloc
{
    self.tableview = nil;
    [super dealloc];
}

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

    CGRect glassRect = CGRectMake(20, 26, 260, 90);
    
    [[UIColor clearColor] setFill];
    UIRectFill(glassRect);
    
    CGRect glassRect1 = CGRectMake(2, 15, 295, 115);
    UIImage *glass = [UIImage imageNamed:@"glass.png"];
    [glass drawInRect:glassRect1];
}

@end
