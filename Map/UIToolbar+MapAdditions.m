//
//  UIToolbar+MapAdditions.m
//  Map
//
//  Created by Scott Sirowy on 8/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIToolbar+MapAdditions.h"

@implementation UIToolbar (UIToolbar_MapAdditions)

-(void)setToolbarBackground:(NSString*)bgFilename
{
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:bgFilename]];
    
    iv.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    iv.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    //might be better to use a specific iOS 5 selector here?
    if([[[UIDevice currentDevice] systemVersion] intValue] >= 5)
        [self insertSubview:iv atIndex:1]; // iOS5 atIndex:1
    else
        [self insertSubview:iv atIndex:0]; // iOS4 atIndex:0
    
    self.backgroundColor = [UIColor clearColor];
    
}

@end
