//
//  UIImage+AppAdditions.m
//  Map
//
//  Created by Scott Sirowy on 10/19/11.
/*
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

#import "UIImage+AppAdditions.h"

@implementation UIImage (AppAdditions)

- (UIImage *)overlayWithImage:(UIImage *)image2 {
    UIImage *image1 = self;
    CGRect drawRect = CGRectMake(0.0, 0.0, image1.size.width, image1.size.height);
    
    // Create the bitmap context
    CGContextRef    bitmapContext = NULL;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    CGSize          size = CGSizeMake(image1.size.width, image1.size.height);
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (size.width * 4);
    bitmapByteCount     = (bitmapBytesPerRow * size.height);
    
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL)
    {
        return nil;
    }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    bitmapContext = CGBitmapContextCreate (bitmapData, size.width, size.height,8,bitmapBytesPerRow,
                                           colorSpace,kCGImageAlphaNoneSkipFirst);
    
    CGColorSpaceRelease(colorSpace);
    
    if (bitmapContext == NULL)
        // error creating context
        return nil;
    
    // Draw the image to the bitmap context. Once we draw, the memory
    // allocated for the context for rendering will then contain the
    // raw image data in the specified color space.
    CGContextDrawImage(bitmapContext, drawRect, [image1 CGImage]);
    CGContextDrawImage(bitmapContext, drawRect, [image2 CGImage]);
    CGImageRef   img = CGBitmapContextCreateImage(bitmapContext);
    UIImage*     ui_img = [UIImage imageWithCGImage: img];
    
    CGImageRelease(img);
    CGContextRelease(bitmapContext);
    free(bitmapData);
    
    return ui_img;
}

@end
