//
//  StreetSignView.m
//  StreetSignTest
//
//  Created by Scott Sirowy on 11/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "StreetSignView.h"
#import "Direction.h"
#import "OverviewDirection.h"

//#define USE_STREET_SIGN_COLOR 1

@interface StreetSignView () 

-(UIFont *)fittedFontForString:(NSString *)aString withFont:(UIFont *)font inWidth:(CGFloat)width;

@end

@implementation StreetSignView

@synthesize direction = _direction;


- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame withDirection:nil withReflectionSlope:0 startingX:0 useShadow:NO];
}

-(id)initWithFrame:(CGRect)frame withDirection:(Direction *)direction withReflectionSlope:(CGFloat)slope startingX:(CGFloat)x useShadow:(BOOL)useShadow;
{
    self = [super initWithFrame:frame withReflectionSlope:slope startingX:x useShadow:useShadow];
    if(self)
    {
        self.direction = direction;
    }
    return self;
}


-(UIFont *)fittedFontForString:(NSString *)aString withFont:(UIFont *)font inWidth:(CGFloat)width
{
    UIFont *fontToReturn = font;
    CGSize maximumLabelSize = CGSizeMake(width,9999);
    
    CGSize expectedLabelSize = [aString sizeWithFont:fontToReturn 
                                   constrainedToSize:maximumLabelSize 
                                       lineBreakMode:UILineBreakModeWordWrap];
    
    while(expectedLabelSize.height > font.lineHeight)
    {
        fontToReturn = [fontToReturn fontWithSize:fontToReturn.pointSize - 1];
        expectedLabelSize = [aString sizeWithFont:fontToReturn 
                                constrainedToSize:maximumLabelSize 
                                    lineBreakMode:UILineBreakModeWordWrap];        
    }
    
    return fontToReturn;
}


- (void)drawRect:(CGRect)rect
{
    // get the contect
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //draw the frame of sign
    [super drawRect:rect];
    
    CGRect contentRect = [self calculateContentRect:rect];
    
    CGFloat imageInset = 5.0;
    CGFloat imageHeight = contentRect.size.height - 2*imageInset;
    CGRect imageRect = CGRectMake(contentRect.origin.x + imageInset, contentRect.origin.y + imageInset, imageHeight, imageHeight);
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    
    CGFloat streetNameOriginX = imageRect.origin.x + imageRect.size.width;
    
    [self.direction.icon drawInRect:imageRect];
    
    if ([self.direction isKindOfClass:[OverviewDirection class]]) 
    {
        CGFloat centeringOffset = 3.0;
        CGFloat halfImageHeight = imageHeight/2;
        CGFloat yDistanceOffset = imageInset*2 + centeringOffset;
        CGFloat yTimeOffset     = yDistanceOffset + halfImageHeight;
        
        CGRect distanceLabelRect    = CGRectMake(streetNameOriginX+centeringOffset, yDistanceOffset, contentRect.size.width-streetNameOriginX, halfImageHeight);
        CGRect timeLabelRect        = CGRectMake(streetNameOriginX+centeringOffset, yTimeOffset, contentRect.size.width-streetNameOriginX, halfImageHeight);
        
        CGRect distanceValueRect    = CGRectMake(contentRect.size.width/2, yDistanceOffset, contentRect.size.width/2-centeringOffset, halfImageHeight);
        CGRect timeValueRect        = CGRectMake(contentRect.size.width/2, yTimeOffset, contentRect.size.width/2-centeringOffset, halfImageHeight);
        
        UIFont *labelFont = [UIFont fontWithName:@"Arial-BoldMT" size:18.0];
        
        [@"Distance"  drawInRect:distanceLabelRect 
                              withFont:labelFont 
                         lineBreakMode:UILineBreakModeWordWrap 
                             alignment:UITextAlignmentLeft];
        
        [@"Travel Time"  drawInRect:timeLabelRect 
                        withFont:labelFont 
                   lineBreakMode:UILineBreakModeWordWrap 
                       alignment:UITextAlignmentLeft];
        
        [self.direction.distanceString drawInRect:distanceValueRect 
                                         withFont:labelFont 
                                    lineBreakMode:UILineBreakModeWordWrap 
                                        alignment:UITextAlignmentRight];
        
        [self.direction.etaString drawInRect:timeValueRect 
                                    withFont:labelFont 
                               lineBreakMode:UILineBreakModeWordWrap 
                                   alignment:UITextAlignmentRight];
    }
    else
    {
        CGRect streetNameRect = CGRectMake(streetNameOriginX, imageInset*2, contentRect.size.width-streetNameOriginX, imageHeight/2);
        
        UIFont *signFont = [self fittedFontForString:self.direction.abbreviatedName 
                                            withFont:[UIFont fontWithName:@"Arial-BoldMT" size:30.0] 
                                             inWidth:streetNameRect.size.width];
        
        [self.direction.abbreviatedName  drawInRect:streetNameRect 
                                           withFont:signFont 
                                      lineBreakMode:UILineBreakModeWordWrap 
                                          alignment:UITextAlignmentLeft];
        
        
        CGFloat distanceHeight = imageHeight/2;
        CGFloat distanceOriginY = (imageRect.origin.y + imageRect.size.height) -distanceHeight + 5;
        CGRect distanceRect = CGRectMake(streetNameOriginX, distanceOriginY, streetNameRect.size.width/2, distanceHeight);
        
        UIFont *distanceFont = [UIFont fontWithName:@"Arial-BoldMT" size:18.0];
        [self.direction.distanceString drawInRect:distanceRect 
                                         withFont:distanceFont 
                                    lineBreakMode:UILineBreakModeWordWrap 
                                        alignment:UITextAlignmentLeft];
        
        
        CGRect etaRect = CGRectMake(streetNameOriginX + streetNameRect.size.width/2, distanceOriginY + 3, streetNameRect.size.width/2 - 10, distanceHeight);
        
        UIFont *etaFont = [UIFont fontWithName:@"Arial" size:14.0];
        [self.direction.etaString drawInRect:etaRect 
                                    withFont:etaFont 
                               lineBreakMode:UILineBreakModeWordWrap 
                                   alignment:UITextAlignmentRight];
    }
}


@end
