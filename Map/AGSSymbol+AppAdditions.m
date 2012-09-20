//
//  AGSSymbol+AppAdditions.m
//  Map
//
//  Created by Scott Sirowy on 12/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AGSSymbol+AppAdditions.h"

@implementation AGSSymbol (AppAdditions)

//returns a normalized version of the symbol. Normalized meaning the offset is changed to (0,0)
-(AGSSymbol *)normalize
{
    return [[self copy] autorelease];
}


@end

@implementation AGSMarkerSymbol (AppAdditions)

//returns a normalized version of the symbol. Normalized meaning the offset is changed to (0,0)
-(AGSMarkerSymbol *)normalize
{
    AGSMarkerSymbol *ms = [self copy];
    ms.xoffset = 0;
    ms.yoffset = 0;
    
    return [ms autorelease];
}


@end

@implementation AGSCompositeSymbol (AppAdditions)

//returns a normalized version of the symbol. Normalized meaning the offset is changed to (0,0)
//This implementation assumes no symbol is itself a composite symbol and is a marker symbol
-(AGSSymbol *)normalize
{
    AGSCompositeSymbol *cs = [self copy];
    
    AGSMarkerSymbol *firstMarkerSymbol = (AGSMarkerSymbol *)[cs.symbols objectAtIndex:0];
    
    CGFloat xDelta = firstMarkerSymbol.xoffset;
    CGFloat yDelta = firstMarkerSymbol.yoffset;
    
    firstMarkerSymbol.xoffset = 0;
    firstMarkerSymbol.yoffset = 0;
    
    for(int i = 1; i < cs.symbols.count; i++)
    {
        AGSMarkerSymbol *ms = [cs.symbols objectAtIndex:i];
        ms.xoffset -= xDelta;
        ms.yoffset -= yDelta;
    }
    
    return [cs autorelease];
}

@end
