/*
 Copyright © 2013 Esri
 
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
    ms.offset = CGPointMake(0,0);
    
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
    
    CGPoint pDelta = firstMarkerSymbol.offset;
   
    firstMarkerSymbol.offset = CGPointMake(0, 0);
    
    for(int i = 1; i < cs.symbols.count; i++)
    {
        AGSMarkerSymbol *ms = [cs.symbols objectAtIndex:i];
        ms.offset = CGPointMake(ms.offset.x - pDelta.x, ms.offset.y - pDelta.y);
    }
    
    return cs;
}

@end
