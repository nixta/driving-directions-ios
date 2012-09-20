//
//  AGSSymbol+AppAdditions.h
//  Map
//
//  Created by Scott Sirowy on 12/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ArcGIS+App.h"

@interface AGSSymbol (AppAdditions)

-(AGSSymbol *)normalize;

@end

@interface AGSMarkerSymbol (AppAdditions)

-(AGSMarkerSymbol *)normalize;

@end

@interface AGSCompositeSymbol (AppAdditions)

-(AGSCompositeSymbol *)normalize;

@end
