//
//  DirectionsPrintRenderer.m
//  Map
//
//  Created by Scott Sirowy on 10/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DirectionsPrintRenderer.h"
#import "DirectionsList.h"
#import "Direction.h"

#define kNumberOfDirectionsPerPage 10
#define kLeftMargin 72
#define kRightMargin 72
#define kTopMargin 50

#define kDirectionHeight 50
#define kImageHeight 35
#define kImagePrintBuffer 15

@implementation DirectionsPrintRenderer

@synthesize directions = _directions;


-(id)initWithDirections:(DirectionsList *)list
{
    self = [super init];
    if(self)
    {
        self.directions = list;
    }
    
    return self;
}

// This code always draws one image at print time.
-(NSInteger)numberOfPages
{
    int numPages =  [self.directions numberOfItems]/kNumberOfDirectionsPerPage;
    if ([self.directions numberOfItems]%kNumberOfDirectionsPerPage != 0) {
        numPages++;
    }
    
    return numPages;
}

-(void)drawFooterForPageAtIndex:(NSInteger)pageIndex inRect:(CGRect)footerRect
{
    [NSLocalizedString(@"ArcGIS Map. Copyright 2011", nil) drawInRect:footerRect 
                                             withFont:[UIFont systemFontOfSize:7.0] 
                                        lineBreakMode:UILineBreakModeTailTruncation 
                                            alignment:UITextAlignmentCenter];
}

-(void)drawContentForPageAtIndex:(NSInteger)pageIndex inRect:(CGRect)contentRect
{
    int startIndex = pageIndex*kNumberOfDirectionsPerPage;
    
    CGFloat imageInitialTopMargin = kTopMargin + ((kDirectionHeight - kImageHeight)/2);
    CGRect imageRect = CGRectMake(kLeftMargin, imageInitialTopMargin, kImageHeight, kImageHeight);
    
    CGFloat directionLeftMargin = kLeftMargin + kImageHeight + kImagePrintBuffer;
    CGFloat directionWidth = contentRect.size.width - kRightMargin - directionLeftMargin;
    
    CGRect directionRect = CGRectMake(directionLeftMargin, kTopMargin, directionWidth, kDirectionHeight);
    
    CGSize widthConstraint = CGSizeMake(directionRect.size.width, 20000.0f);
    
    for(int i = startIndex; i < startIndex + kNumberOfDirectionsPerPage; i++)
    {
        UITextAlignment textAlignment = (i) ? UITextAlignmentLeft : UITextAlignmentCenter;
        
        Direction *dir = [self.directions directionAtIndex:i];
        [dir.icon drawInRect:imageRect];
        
        CGSize contrainedSize = [dir.name sizeWithFont:[UIFont systemFontOfSize:14] 
                            constrainedToSize:widthConstraint 
                                lineBreakMode:UILineBreakModeWordWrap];
        
        
        CGRect textRect = CGRectMake(directionRect.origin.x, directionRect.origin.y + ((directionRect.size.height - contrainedSize.height)/2), 
                                     directionRect.size.width, directionRect.size.height);
        
        [dir.name drawInRect:textRect
                  withFont:[UIFont systemFontOfSize:14] 
             lineBreakMode:UILineBreakModeWordWrap 
                 alignment:textAlignment];
        
        imageRect.origin.y += kDirectionHeight;
        directionRect.origin.y += kDirectionHeight;
    }
}


@end
