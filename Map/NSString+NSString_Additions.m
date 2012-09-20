//
//  NSString+NSString_Additions.m
//  Map
//
//  Created by Scott Sirowy on 10/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NSString+NSString_Additions.h"

@implementation NSString (NSString_Additions)

-(NSString *) stringMinusFirstLetterCaptialization
{
    return [NSString stringWithFormat:@"%@%@",[[self substringToIndex:1] lowercaseString],[self substringFromIndex:1]];
}

@end
