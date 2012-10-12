/*
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

#import "SplashImageVC.h"
#import "ArcGISAppDelegate.h"

#define kIPadSplashLandscape	@"iPadSplash-Landscape.png"
#define kIPadSplashPortrait		@"iPadSplash.png"
#define kIPhoneSplash			@"Default.png"

@implementation SplashImageVC

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {

	_app = (ArcGISAppDelegate *)[UIApplication sharedApplication].delegate;
	
	CGRect rect = [[UIScreen mainScreen] bounds];
	
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	
	int statusBarHeight = 0;
	
	// the offset of 20 is here is for the status bar
	UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, statusBarHeight, rect.size.width, rect.size.height-statusBarHeight)];
	
	// By default we load the portrait version, we will NOT know at this point if we are landscape
	// I kept getting UIInterfaceOrientationUnknown if it was landscape...
	// This will get switched out if we get a didRotate... message
	if (_app.isIPad) {
		iv.image = [UIImage imageNamed:kIPadSplashPortrait];
	}
	else {
		iv.image = [UIImage imageNamed:kIPhoneSplash];
	}
	
	iv.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	iv.autoresizesSubviews = YES;
	self.view = iv;
	
	// release because the main view will retain it
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Returning YES when the app is returning YES
	
	BOOL retValue = YES;
    if (!_app.isIPad)
    {
        retValue = (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    }
    
    return retValue;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	
	// we ONLY need to change the image if we are on an iPad and we have landscape
	// 
	// The default is portrait for all, set in loadView
	// and we only support landscape (launching) on the iPad for now
	if (_app.isIPad) {
		if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || 
			self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
			((UIImageView*)self.view).image = [UIImage imageNamed:kIPadSplashLandscape];
		}
	}	
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}


@end
