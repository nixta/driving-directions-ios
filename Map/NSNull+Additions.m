//
//  NSNull+Additions.m
//  Map
//
//  Created by Scott Sirowy on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NSNull+Additions.h"

@implementation NSNull (Additions)

-(UIImage *)icon
{
    return [UIImage imageNamed:@"GPSDisplayStart.png"];
}

-(NSString *)searchString
{
    return NSLocalizedString(@"  Current Location", nil);
}

-(void)updateSymbol
{
    //no op
}

-(void)setLocationType:(LocationType)type
{
    //no op
}

@end
