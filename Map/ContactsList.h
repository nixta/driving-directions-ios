//
//  ContactsList.h
//  Map
//
//  Created by Scott Sirowy on 10/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DrawableList.h"

@interface ContactsList : DrawableList
{
    NSArray         *_sectionTitles;
    NSMutableArray  *_sections;
}

@property (nonatomic, strong, readonly) NSArray *sectionTitles;

@end
