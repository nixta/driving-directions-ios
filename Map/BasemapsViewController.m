//
//  BasemapsViewController.m
//  Map
//
//  Created by Scott Sirowy on 9/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BasemapsViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "MapAppSettings.h"
#import "UIColor+Additions.h"
#import "Basemaps.h"
#import "AGSWebMap+Additions.h"
#import "ArcGIS+App.h"
#import "ContentItem.h"

@interface BasemapsViewController () 

-(void)loadScrollViewWithPage:(int)page;
-(void)animateActivityIndicator:(BOOL)animate;
-(void)setupScrollView;

-(void)startWatchdogTimer;
-(void)stopWatchdogTimer;
-(void)watchdogTimerTimedOut;

-(void)startDownloadingBasemapIcons;
-(void)startIconDownloadForBasemap:(BasemapInfo *)basemap atIndex:(NSUInteger)index withSize:(CGSize)size;
-(void)finishBasemapButtonSetupForIndex:(NSUInteger)index;

-(void)basemapTapped:(id)sender;

@property (nonatomic, retain) NSMutableArray            *views;
@property (nonatomic, retain) UIActivityIndicatorView   *activityIndicator;
@property (nonatomic, retain) NSTimer                   *watchdogTimer;
@property (nonatomic, retain) UIView                    *currentBasemapView;
@property (nonatomic, retain) NSMutableDictionary       *imageDownloadsInProgress;
@property (nonatomic, retain) NSMutableArray            *basemapButtons;

@end

#define kScrollViewFrameWidth 180
#define kImageHeight 120
#define kWatchDogTimeout 5

@implementation BasemapsViewController

@synthesize scrollView = _scrollView;
@synthesize basemaps = _basemaps;
@synthesize delegate = _delegate;

@synthesize views = _views;
@synthesize activityIndicator = _activityIndicator;
@synthesize watchdogTimer = _watchdogTimer;
@synthesize currentBasemapView = _currentBasemapView;
@synthesize imageDownloadsInProgress = _imageDownloadsInProgress;
@synthesize basemapButtons = _basemapButtons;

#pragma mark -
#pragma mark Init/Dealloc Methods

-(void)dealloc
{
    self.scrollView = nil;
    self.basemaps = nil;
    self.views = nil;
    self.activityIndicator = nil;
    self.watchdogTimer = nil;
    self.currentBasemapView = nil;
    self.imageDownloadsInProgress = nil;
    self.basemapButtons = nil;
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _currentBasemap = 0;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark -
#pragma mark Public Methods
//Moves the current basemap view to the basemap that was just selected
-(void)successfullyChangedBasemap
{     
     [self.currentBasemapView removeFromSuperview];
     UIView *bmView = [self.views objectAtIndex:_currentBasemap];
     [bmView addSubview:self.currentBasemapView];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    
    self.view.backgroundColor = [UIColor offWhiteColor];
    self.scrollView.backgroundColor = [UIColor offWhiteColor];
    
    if (!self.basemaps.finishedDownloading) {
        [self animateActivityIndicator:YES];
        [self.basemaps startDownload];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.views = nil;
    self.scrollView = nil;
    self.activityIndicator = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)setupScrollView
{
     NSUInteger numberOfBasemaps = [self.basemaps numberOfBasemaps];
     
     self.views = [NSMutableArray arrayWithCapacity:numberOfBasemaps];
     for (unsigned i = 0; i < numberOfBasemaps; i++)
     {
     [self.views addObject:[NSNull null]];
     }
     
     CGRect sv = self.scrollView.frame;
     sv.size = CGSizeMake(kScrollViewFrameWidth, kScrollViewFrameWidth);
     sv.origin.x = (self.view.frame.size.width -kScrollViewFrameWidth)/2;
     self.scrollView.frame = sv;
     self.scrollView.clipsToBounds = NO;
     
     //Configure scroll view   
     self.scrollView.pagingEnabled = YES;
     self.scrollView.bounces = YES;
     self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width*numberOfBasemaps, self.scrollView.frame.size.height);
     self.scrollView.showsVerticalScrollIndicator = NO;
     self.scrollView.showsHorizontalScrollIndicator = NO;
     self.scrollView.delegate = self;
     
     self.view.backgroundColor = [UIColor clearColor];
     self.scrollView.backgroundColor = [UIColor clearColor];
     
     
     UIImageView *maskView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"basemaps_mask.png"]];
     maskView.userInteractionEnabled = NO;
     maskView.frame = self.view.frame;
     [self.view addSubview:maskView];
     [maskView release];
     
     _currentPage = 0;
     
     [self loadScrollViewWithPage:-1];
     [self loadScrollViewWithPage:0];
     [self loadScrollViewWithPage:1];
}

-(void)loadScrollViewWithPage:(int)page
{
    if (page < 0)
        return;
    if (page >= [self.basemaps numberOfBasemaps])
        return;
    
    // replace the placeholder if necessary
    UIView *view = [self.views objectAtIndex:page];
    if ((NSNull *)view == [NSNull null])
    {
        view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScrollViewFrameWidth - 20, kScrollViewFrameWidth -20)] autorelease];
        view.backgroundColor = [UIColor clearColor];
                        
        UIButton *basemapButton = [UIButton buttonWithType:UIButtonTypeCustom];
        basemapButton.frame = CGRectMake(0, 0, view.frame.size.width, kImageHeight);
        
        //initially hide until 
        basemapButton.hidden = YES;
        
        //Tag so we can identify if its tapped later
        basemapButton.tag = page;
        [basemapButton addTarget:self action:@selector(basemapTapped:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:basemapButton];
        
        //retain for conveneince of adding icon later
        if (_basemapButtons == nil) {
            self.basemapButtons = [NSMutableArray arrayWithCapacity:[self.basemaps numberOfBasemaps]];
        }
        [self.basemapButtons addObject:basemapButton];
        
        if (page == _currentBasemap) {
            [view addSubview:self.currentBasemapView];
        }
        
        [self.views replaceObjectAtIndex:page withObject:view];
        
        BasemapInfo *bmInfo = [self.basemaps basemapAtIndex:page];
        
        if (bmInfo.basemapIcon) {
            [self finishBasemapButtonSetupForIndex:page];
        }
    }
    
    // add the controller's view to the scroll view
    if (view.superview == nil)
    {
		CGRect viewFrame = view.frame;
		viewFrame.origin.x = kScrollViewFrameWidth * page + 10;
		viewFrame.origin.y = 10;
		
		view.frame = viewFrame;
        
        [self.scrollView addSubview:view];
    }
}

-(void)animateActivityIndicator:(BOOL)animate
{
    if(animate)
    {
        if (self.activityIndicator.superview == nil) {
            [self.view addSubview:self.activityIndicator];
            self.activityIndicator.hidden = NO;
            [self.activityIndicator startAnimating];
        }
    }
    else
    {
        [self.activityIndicator removeFromSuperview];
        self.activityIndicator = nil;
    }
}

#pragma mark -
#pragma mark ScrollView Delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{	
    // Calculate which page is visible 
	CGFloat pageWidth = self.scrollView.frame.size.width;
	_currentPage = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    [self loadScrollViewWithPage:_currentPage-1];
    [self loadScrollViewWithPage:_currentPage];
    [self loadScrollViewWithPage:_currentPage+1];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(_currentPage != _currentBasemap)
    {
        [self stopWatchdogTimer];
        [self startWatchdogTimer];
    }
}

#pragma mark -
#pragma mark Basemaps Delegate
-(void)basemapsFinishedDownloading
{
    [self startDownloadingBasemapIcons]; 
    [self animateActivityIndicator:NO];
    [self setupScrollView];
}

-(void)basemapsFailedDownloading
{
    NSLog(@"Failed Downloading!");
}

#pragma mark -
#pragma mark IconDownloader Delegate
-(void)image:(UIImage *)image didLoadForIndexPath:(NSIndexPath *)indexPath
{
    BasemapInfo *bmInfo = [self.basemaps basemapAtIndex:indexPath.row];
    bmInfo.basemapIcon = image;
    [self finishBasemapButtonSetupForIndex:indexPath.row];
}

#pragma mark -
#pragma mark Icon Downloader Support
-(void)startDownloadingBasemapIcons
{
    NSUInteger numBasemaps = [self.basemaps numberOfBasemaps];
    for(int i = 0; i < numBasemaps; i++)
    {
        BasemapInfo *bmInfo = [self.basemaps basemapAtIndex:i];
        [self startIconDownloadForBasemap:bmInfo 
                                  atIndex:i 
                                 withSize:CGSizeMake(kScrollViewFrameWidth - 20, kImageHeight)];
    }
}

- (void)startIconDownloadForBasemap:(BasemapInfo *)basemap atIndex:(NSUInteger)index withSize:(CGSize)size
{    
    //don't need to download icon for default map
    if (basemap.isDefaultBasemap) {
        basemap.basemapIcon = [UIImage imageNamed:@"SampleMapThumb.png"];
    }
    
    //if there is already an icon, we are done
    if (basemap.basemapIcon)
        return;

    NSString *urlString = [basemap mapThumbnailURLString];
    NSIndexPath *anIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    IconDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:anIndexPath];
    
    if (iconDownloader == nil) 
    {        
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.content = basemap;
        iconDownloader.indexPathInTableView = anIndexPath;
        iconDownloader.size = size;
        iconDownloader.delegate = self;
        [self.imageDownloadsInProgress setObject:iconDownloader forKey:anIndexPath];
        [iconDownloader startDownloadWithUrlString:urlString];
        [iconDownloader release];   
    }
}

#pragma mark -
#pragma mark Basemaps Methods
-(void)basemapTapped:(id)sender
{    
    UIButton *basemapButton = (UIButton *)sender;
    int basemapIndex = basemapButton.tag;
    
    if (basemapIndex == _currentBasemap)
        return;
    
    _currentBasemap = basemapIndex;
    
    BasemapInfo *bmInfo = [self.basemaps basemapAtIndex:basemapIndex];
    
    if([self.delegate respondsToSelector:@selector(basemapsViewController:wantsToChangeToNewBasemap:)])
    {
        [self.delegate basemapsViewController:self wantsToChangeToNewBasemap:bmInfo];
        
        //kill watchdog timer while we wait
        [self stopWatchdogTimer];
    }
}

-(void)finishBasemapButtonSetupForIndex:(NSUInteger)index
{
    UIView *view = [self.views objectAtIndex:index];
    
    //can't do anything if the view hasn't been setup yet. Will lazily loaded later
    if ((NSNull *)view == [NSNull null])
        return;
    
    
    UIButton *button = [self.basemapButtons objectAtIndex:index];
    BasemapInfo *bmInfo = [self.basemaps basemapAtIndex:index];
    
    [button setImage:bmInfo.basemapIcon forState:UIControlStateNormal];
    
    //add some shadow to basemap button
    button.layer.shadowColor = [UIColor blackColor].CGColor;
    button.layer.shadowOpacity = 0.8;
    button.layer.shadowRadius = 12;
    button.layer.shadowOffset = CGSizeMake(0.0f, 10.0f);
    
    //unhide button
    button.hidden = NO;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, button.frame.size.height + 10, view.frame.size.width, 25)];
    label.text = bmInfo.title;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:16];
    label.textAlignment = UITextAlignmentCenter;
    [view addSubview:label];
    [label release]; 
}
                            

#pragma mark -
#pragma mark Timer Methods
-(void)startWatchdogTimer
{
    self.watchdogTimer = [NSTimer scheduledTimerWithTimeInterval:kWatchDogTimeout 
                                                 target:self 
                                               selector:@selector(watchdogTimerTimedOut) 
                                               userInfo:nil 
                                                repeats:NO];
    
}

-(void)stopWatchdogTimer
{
    [self.watchdogTimer invalidate];
    self.watchdogTimer = nil;
}

-(void)watchdogTimerTimedOut
{
    [self.scrollView scrollRectToVisible:CGRectMake(_currentBasemap*kScrollViewFrameWidth, 0, kScrollViewFrameWidth, kScrollViewFrameWidth) 
                                animated:YES];
    
    [self stopWatchdogTimer];
}

#pragma mark -
#pragma mark Lazy Loads

-(UIActivityIndicatorView *)activityIndicator
{
    if(_activityIndicator == nil)
    {
        UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        aiv.center = self.scrollView.center;
        
        self.activityIndicator = aiv;
        [aiv release];
    }
    
    return _activityIndicator;
}

-(Basemaps *)basemaps
{
    if(_basemaps == nil)
    {
        Basemaps *bm = [[Basemaps alloc] initWithDelegate:self];
        self.basemaps = bm;
        [bm release];
    }
    
    return _basemaps;
}

-(UIView *)currentBasemapView
{
    if(_currentBasemapView == nil)
    {
        CGFloat viewHeight = 20;
        UIView *cbv = [[UIView alloc] initWithFrame:CGRectMake(0, kImageHeight - viewHeight, kScrollViewFrameWidth - 20, viewHeight)];
        cbv.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.75];
        
        UILabel *currentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cbv.frame.size.width, cbv.frame.size.height)];
        currentLabel.font = [UIFont boldSystemFontOfSize:12.0];
        currentLabel.backgroundColor = [UIColor clearColor];
        currentLabel.textColor = [UIColor whiteColor];
        currentLabel.textAlignment = UITextAlignmentCenter;
        currentLabel.text = NSLocalizedString(@"Current", nil);
        
        [cbv addSubview:currentLabel];
        [currentLabel release];
        
        self.currentBasemapView = cbv;
        [cbv release];
    }
    
    return _currentBasemapView;
}

@end
