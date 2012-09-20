//
//  Search.h
//  Map
//
//  Created by Scott Sirowy on 9/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TableViewDrawable.h"

/*
 Represents a search the user made. Conforms to TableViewDrawable
 protocol so it can be presented nicely in a tableview with
 other searches and search results
 */

@interface Search : NSObject <TableViewDrawable, AGSCoding>
{
    NSString    *_name;
    UIImage     *_icon;
}

@property (nonatomic, copy) NSString    *name;
@property (nonatomic, retain) UIImage   *icon;

-(id)initWithName:(NSString *)name;

@end
