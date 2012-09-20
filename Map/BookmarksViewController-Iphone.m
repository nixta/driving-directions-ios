/*
 BookmarksViewController-Iphone.m
 ArcGISMobile
 
 COPYRIGHT 2011 ESRI
 
 TRADE SECRETS: ESRI PROPRIETARY AND CONFIDENTIAL
 Unpublished material - all rights reserved under the
 Copyright Laws of the United States and applicable international
 laws, treaties, and conventions.
 
 For additional information, contact:
 Environmental Systems Research Institute, Inc.
 Attn: Contracts and Legal Services Department
 380 New York Street
 Redlands, California, 92373
 USA
 
 email: contracts@esri.com
 */

#import "BookmarksViewController-Iphone.h"

//defined here again to prevent "doesn't respond to selector" warnings
@interface BookmarksViewController ()
-(void)doneEditing;
@end

//private anonymous methods for iPhone specific class
@interface BookmarksViewController_Iphone ()
-(void)goBackToMap;
@end


@implementation BookmarksViewController_Iphone

@synthesize mapButton= _mapButton;

//overriding viewDidLoad to add a new button to the iPhone version of the bookmarks view controller
-(void)viewDidLoad
{
	[super viewDidLoad];
	
	UIBarButtonItem *aMapButton = 
        [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Map", nil) 
                                style:UIBarButtonItemStylePlain target:self 
                                action:@selector(goBackToMap)];
	self.mapButton = aMapButton;
	[aMapButton release];
	
	[self currentNavItem].leftBarButtonItem = self.mapButton;
}

//overriding to add the map button back to the view controller when segmented
//control changes
-(IBAction)segmentedControlChanged:(id)sender
{
	[super segmentedControlChanged:sender];
	
	//always put the map button on the screen when user changes
    //segment views
	[self currentNavItem].leftBarButtonItem = self.mapButton;
}

-(void)doneEditing
{
	[super doneEditing];
    
    //always put the map button on the screen when user changes
    //segment views
	[self currentNavItem].leftBarButtonItem = self.mapButton;
}

-(void)goBackToMap
{
	[self dismissModalViewControllerAnimated:YES];
}

-(void)dealloc
{
	self.mapButton = nil;
	[super dealloc];
}

@end
