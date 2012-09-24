//
//  BasemapsViewController.h
//  Map
//
//  Created by Scott Sirowy on 9/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Basemaps.h"
#import "IconDownloader.h"

@class Basemaps;
@protocol ChangeBasemapsDelegate;


/*
 Responsible for displaying a set of basemaps in a nice scrollable way.
 */

@interface BasemapsViewController : UIViewController <UIScrollViewDelegate, BasemapDelegate, IconDownloaderDelegate>
{
    UIScrollView                *_scrollView;
    Basemaps                    *_basemaps;
    id<ChangeBasemapsDelegate>  __unsafe_unretained _delegate;
    
    @private
    int                         _currentPage;
    int                         _currentBasemap;
    NSTimer                     *_watchdogTimer;
    NSMutableArray              *_views;
    UIActivityIndicatorView     *_activityIndicator;
    UIView                      *_currentBasemapView;
    NSMutableDictionary         *_imageDownloadsInProgress;
    NSMutableArray              *_basemapButtons;
}

@property (nonatomic, strong) IBOutlet UIScrollView         *scrollView;
@property (nonatomic, strong) Basemaps                      *basemaps;
@property (nonatomic, unsafe_unretained) id<ChangeBasemapsDelegate>    delegate;

-(void)successfullyChangedBasemap;

@end

@protocol ChangeBasemapsDelegate <NSObject>

@optional
-(void)basemapsViewController:(BasemapsViewController *)bmvc wantsToChangeToNewBasemap:(BasemapInfo *)basemap;

@end
