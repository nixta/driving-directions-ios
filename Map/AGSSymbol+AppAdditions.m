/*
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

#import "AGSSymbol+AppAdditions.h"

@implementation AGSSymbol (AppAdditions)

//returns a normalized version of the symbol. Normalized meaning the offset is changed to (0,0)
-(AGSSymbol *)normalize
{
    return [self copy];
}


@end

@implementation AGSMarkerSymbol (AppAdditions)

//returns a normalized version of the symbol. Normalized meaning the offset is changed to (0,0)
-(AGSMarkerSymbol *)normalize
{
    AGSMarkerSymbol *ms = [self copy];
    ms.xoffset = 0;
    ms.yoffset = 0;
    
    return ms;
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
    
    return cs;
}

@end
