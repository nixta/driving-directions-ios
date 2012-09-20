/*
     File: IconDownloader.m 
 Abstract: Helper object for managing the downloading of a particular app's icon.
 As a delegate "NSURLConnectionDelegate" is downloads the app icon in the background if it does not
 yet exist and works in conjunction with the RootViewController to manage which apps need their icon.
 
 A simple BOOL tracks whether or not a download is already in progress to avoid redundant requests.
  
  Version: 1.0 
  
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple 
 Inc. ("Apple") in consideration of your agreement to the following 
 terms, and your use, installation, modification or redistribution of 
 this Apple software constitutes acceptance of these terms.  If you do 
 not agree with these terms, please do not use, install, modify or 
 redistribute this Apple software. 
  
 In consideration of your agreement to abide by the following terms, and 
 subject to these terms, Apple grants you a personal, non-exclusive 
 license, under Apple's copyrights in this original Apple software (the 
 "Apple Software"), to use, reproduce, modify and redistribute the Apple 
 Software, with or without modifications, in source and/or binary forms; 
 provided that if you redistribute the Apple Software in its entirety and 
 without modifications, you must retain this notice and the following 
 text and disclaimers in all such redistributions of the Apple Software. 
 Neither the name, trademarks, service marks or logos of Apple Inc. may 
 be used to endorse or promote products derived from the Apple Software 
 without specific prior written permission from Apple.  Except as 
 expressly stated in this notice, no other rights or licenses, express or 
 implied, are granted by Apple herein, including but not limited to any 
 patent rights that may be infringed by your derivative works or by other 
 works in which the Apple Software may be incorporated. 
  
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE 
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION 
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS 
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND 
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 
  
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL 
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, 
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED 
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), 
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE 
 POSSIBILITY OF SUCH DAMAGE. 
  
 Copyright (C) 2009 Apple Inc. All Rights Reserved. 
  
 */

#import "IconDownloader.h"
#import "MapSettings.h"
#import "AppSettings.h"
#import "ArcGISOnlineServices.h"
#import "ArcGISOnlineConnection.h"
#import "ArcGIS+App.h"

#define kAppIconHeight 128

@implementation IconDownloader

@synthesize delegate = _delegate;
@synthesize irop = _irop;
@synthesize content = _content;
@synthesize indexPathInTableView = _indexPathInTableView;
@synthesize size = _size;

#pragma mark

-(id)init{
	if (self = [super init]){
		self.size = CGSizeMake(kAppIconHeight, kAppIconHeight);
	}
	return self;
}

- (void)dealloc
{
    self.delegate = nil;
    
    self.content = nil;
    self.indexPathInTableView = nil;
    
    [self.irop cancel];
    self.irop = nil;
    
    [super dealloc];
}

- (void)startDownloadWithUrlString:(NSString *)urlString withHost:(NSString *)host
{
    //NSLog(@"icon url: %@", urlString);
    
    ArcGISAppDelegate *_app = (ArcGISAppDelegate*)[UIApplication sharedApplication].delegate;
    ArcGISOnlineConnection *connection = _app.appSettings.arcGISOnlineConnection;
	
    //NSLog(@"connection url: %@", urlString);
    
	//create the url request, complete with token and referer, if signed in
	NSURLRequest *contentReq = [connection requestForUrlString:urlString withHost:nil];
    
    self.irop = [[[AGSImageRequestOperation alloc] initWithRequest:contentReq] autorelease];
    self.irop.target = self;
    self.irop.action = @selector(imageDownload:didGetImage:);
    self.irop.errorAction = @selector(imageDownload:didFailWithError:);
    [[AGSRequestOperation sharedOperationQueue] addOperation:self.irop];
}

- (void)imageDownload:(AGSImageRequestOperation*)irop didGetImage:(UIImage*)image {
    
    /**
    //    if (image != nil && image.size.width != kAppIconHeight && image.size.height != kAppIconHeight)
    if (image != nil && image.size.width != self.size.width && image.size.height != self.size.height)
	{
        //We want to preserve the aspect ratio of the original image and
        //make it fit into our self.size property.
        
        CGFloat selfSizeRatio = self.size.width / self.size.height;
        CGFloat imageSizeRatio = image.size.width / image.size.height;
        CGSize itemSize;        
        if (imageSizeRatio < selfSizeRatio)
        {
            itemSize = CGSizeMake(self.size.height * imageSizeRatio, self.size.height);
        }
        else
        {
            itemSize = CGSizeMake(self.size.width, self.size.width / imageSizeRatio);
        }
        //        CGSize itemSize = CGSizeMake(kAppIconHeight, kAppIconHeight);
		UIGraphicsBeginImageContext(itemSize);
		CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
		[image drawInRect:imageRect];
        
        //        NSLog(@"original width = %f height = %f;\nnew width = %f height = %f\n", 
        //              image.size.width, image.size.height,
        //              itemSize.width, itemSize.height);
        
        if ([self.content isKindOfClass:[MapSettingsBase class]])
        {
            MapSettingsBase *ms = (MapSettingsBase *)self.content;
            ms.mapIcon = UIGraphicsGetImageFromCurrentImageContext();
        }
        else if ([self.content isKindOfClass:[Group class]])
        {
            Group *group = (Group *)self.content;
            group.groupIcon = UIGraphicsGetImageFromCurrentImageContext();
        }
    }
    else
    {
        if ([self.content isKindOfClass:[MapSettings class]])
        {
            MapSettings *ms = (MapSettings *)self.content;
            ms.mapIcon = image;
        }
        else if ([self.content isKindOfClass:[Group class]])
        {
            Group *group = (Group *)self.content;
            group.groupIcon = image;
        }
    }   **/
    
    // call our delegate and tell it that our icon is ready for display
    if ([self.delegate respondsToSelector:@selector(image:didLoadForIndexPath:)]) 
    {
        //[self.delegate appImageDidLoad:self.indexPathInTableView];
        [self.delegate image:image didLoadForIndexPath:self.indexPathInTableView];
    }
    
    // nil out to release data
    self.irop = nil;
}

- (void)imageDownload:(AGSImageRequestOperation*)iron didFailWithError:(NSError*)error {    
    if ([self.delegate respondsToSelector:@selector(appImageDidFailToLoad:)]) 
    {
        [self.delegate appImageDidFailToLoad:self.indexPathInTableView];
    }
    // nil out to release data
    self.irop = nil;
}

- (void)startDownloadWithUrlString:(NSString *)urlString
{
    [self startDownloadWithUrlString:urlString withHost:nil];
}

- (void)cancelDownload
{
    self.delegate = nil;
    
    [self.irop cancel];
    self.irop = nil;
}

@end

