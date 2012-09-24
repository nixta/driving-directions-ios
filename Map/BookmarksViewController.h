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
    
    id<DrawableContainerDataSource> __unsafe_unretained _bookmarkDataSource;
    id<DrawableContainerDelegate>   __unsafe_unretained _bookmarkDelegate;
    
    id<DrawableContainerDataSource> __unsafe_unretained _contactkDataSource;
    id<DrawableContainerDelegate>   __unsafe_unretained _contactDelegate;
    
    @private
    ArcGISAppDelegate               *__unsafe_unretained _app;
    BOOL                            _showContacts;
    BOOL                            _useNavigationStack;
}

/*IB Resources */
@property (nonatomic, strong) IBOutlet UISegmentedControl       *segmentedControl;
@property (nonatomic, strong) IBOutlet UITableView              *bookmarkTableView;
@property (nonatomic, strong) IBOutlet UIToolbar                *toolbar;

/*Misc. Ux Resources */
@property (nonatomic, strong) UINavigationBar                   *navBar;

/*buttons used for editing(moving, deletion) of bookmarks */
@property (nonatomic, strong) UIBarButtonItem                   *editButton;
@property (nonatomic, strong) UIBarButtonItem                   *doneButton;

/*datasource object that supplies view controller with bookmarks */
@property (nonatomic, unsafe_unretained) id<DrawableContainerDataSource>   bookmarkDataSource;

/*delegate that responds to a bookmark being selected */
@property (nonatomic, unsafe_unretained) id<DrawableContainerDelegate>     bookmarkDelegate;

/*datasource object that supplies view controller with bookmarks */
@property (nonatomic, unsafe_unretained) id<DrawableContainerDataSource>   contactDataSource;

/*delegate that responds to a bookmark being selected */
@property (nonatomic, unsafe_unretained) id<DrawableContainerDelegate>     contactDelegate;

@property (nonatomic, assign) BOOL                              showContacts;

-(id)initUsingNavigationControllerStack:(BOOL)usingNavigationControllerStack;

-(IBAction)segmentedControlChanged:(id)sender;
-(void)doneEditing;
-(UINavigationItem *)currentNavItem;

@end
