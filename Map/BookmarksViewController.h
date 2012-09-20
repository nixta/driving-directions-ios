/*
 BookmarksViewController.h
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



//BookmarkViewController shows all of the web map bookmarks, user-defined 
//bookmarks, and bookmarks created from the user's contacts in one location
//A user can edit and select bookmarks that will be viewed on the main map 
//view
//This class is meant to be a base class, and should be subclassed for iPhone
//and iPad specific implementations

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import "GeocodeService.h"
#import "DrawableContainerDelegate.h"

@class ArcGISAppDelegate;

/*
 Enter description here
 */

@interface BookmarksViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    UIToolbar                       *_toolbar;
    UISegmentedControl              *_segmentedControl;
    UITableView                     *_bookmarkTableView;

    UIBarButtonItem                 *_editButton;
    UIBarButtonItem                 *_doneButton;
    
    UINavigationBar                 *_navBar;
    
    id<DrawableContainerDataSource> _bookmarkDataSource;
    id<DrawableContainerDelegate>   _bookmarkDelegate;
    
    id<DrawableContainerDataSource> _contactkDataSource;
    id<DrawableContainerDelegate>   _contactDelegate;
    
    @private
    ArcGISAppDelegate               *_app;
    BOOL                            _showContacts;
    BOOL                            _useNavigationStack;
}

/*IB Resources */
@property (nonatomic, retain) IBOutlet UISegmentedControl       *segmentedControl;
@property (nonatomic, retain) IBOutlet UITableView              *bookmarkTableView;
@property (nonatomic, retain) IBOutlet UIToolbar                *toolbar;

/*Misc. Ux Resources */
@property (nonatomic, retain) UINavigationBar                   *navBar;

/*buttons used for editing(moving, deletion) of bookmarks */
@property (nonatomic, retain) UIBarButtonItem                   *editButton;
@property (nonatomic, retain) UIBarButtonItem                   *doneButton;

/*datasource object that supplies view controller with bookmarks */
@property (nonatomic, assign) id<DrawableContainerDataSource>   bookmarkDataSource;

/*delegate that responds to a bookmark being selected */
@property (nonatomic, assign) id<DrawableContainerDelegate>     bookmarkDelegate;

/*datasource object that supplies view controller with bookmarks */
@property (nonatomic, assign) id<DrawableContainerDataSource>   contactDataSource;

/*delegate that responds to a bookmark being selected */
@property (nonatomic, assign) id<DrawableContainerDelegate>     contactDelegate;

@property (nonatomic, assign) BOOL                              showContacts;

-(id)initUsingNavigationControllerStack:(BOOL)usingNavigationControllerStack;

-(IBAction)segmentedControlChanged:(id)sender;
-(void)doneEditing;
-(UINavigationItem *)currentNavItem;

@end
