//
//  NSNull+Additions.h
//  Map
//
//  Created by Scott Sirowy on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Location.h"

@interface NSNull (Additions)

-(UIImage *)icon;
-(NSString *)searchString;
-(void)updateSymbol;
-(void)setLocationType:(LocationType)type;

@end
