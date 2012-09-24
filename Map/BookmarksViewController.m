/*
 BookmarksViewController.m
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

#import "BookmarksViewController.h"
#import "MapAppDelegate.h"
#import "UIColor+Additions.h"
#import "ContactsManager.h"
#import "ArcGIS+App.h"
#import "DrawableList.h"
#import "NamedGeometry.h"

//constants for the two segmented controls on view
#define kBookmarksIndex 0
#define kContactsIndex 1

@interface BookmarksViewController ()

-(BOOL)showEditButton;
-(void)setupEditButton;
-(void)editMode;
-(void)setupSegmentedControl;

@property (nonatomic, copy) NSString            *contactsName;
@property (nonatomic, unsafe_unretained) ArcGISAppDelegate *app;

@end

@implementation BookmarksViewController

@synthesize segmentedControl= _segmentedControl;
@synthesize bookmarkTableView= _bookmarkTableView;
@synthesize toolbar = _toolbar;
@synthesize editButton= _editButton;
@synthesize doneButton= _doneButton;
@synthesize contactsName = _contactsName;
@synthesize navBar = _navBar;

@synthesize bookmarkDataSource = _bookmarkDataSource;
@synthesize bookmarkDelegate= _bookmarkDelegate;
@synthesize contactDataSource = _contactkDataSource;
@synthesize contactDelegate = _contactDelegate;

@synthesize showContacts = _showContacts;

@synthesize app = _app;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //default YES
        _showContacts = YES;
        
        _useNavigationStack = NO;
    }
    return self;
}

//default initializer
-(id)initUsingNavigationControllerStack:(BOOL)usingNavigationControllerStack
{
    self = [self initWithNibName:@"BookmarksViewController" bundle:nil];
    if(self)
    {
        _useNavigationStack = usingNavigationControllerStack;
    }
    
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //have to add nav controller ourselves
    if(!_useNavigationStack)
    {
        UINavigationBar *nb = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        nb.barStyle = UIBarStyleBlackOpaque;
        UINavigationItem *navItem = [[UINavigationItem alloc] init];
        [nb pushNavigationItem:navItem animated:NO];
        
        self.navBar = nb;
        
        [self.view addSubview:self.navBar];
        
        //move down tableview
        CGRect tableViewRect = self.bookmarkTableView.frame;
        tableViewRect.origin.y += self.navBar.frame.size.height;
        tableViewRect.size.height -= self.navBar.frame.size.height;
        
        self.bookmarkTableView.frame = tableViewRect;
    }
    else
    {
        self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    }

    //initialize navigation item
    [[self currentNavItem] setHidesBackButton:YES];
    [self currentNavItem].title = NSLocalizedString(@"Bookmarks", nil);
    [self currentNavItem].leftBarButtonItem.enabled = NO;    

    self.view.backgroundColor = [UIColor darkBackgroundColor];
    
    [self setupSegmentedControl];

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(addressBookChanged:) name:@"AddressBookContactChange" object:nil];
}

//if bookmarks have been added since opening last time, tableview needs to reload
//its data
-(void)viewWillAppear:(BOOL)animated
{
    [self setupEditButton];

    [self.bookmarkTableView reloadData];
}

//depending on if we are using the navigation stack or not, give back a navigation 
//item to write to
-(UINavigationItem *)currentNavItem
{
    return (_useNavigationStack) ? self.navigationItem : self.navBar.topItem;
}

#pragma mark -
#pragma mark Custom Setters
-(void)setShowContacts:(BOOL)showContacts
{
    _showContacts = showContacts;
    [self setupSegmentedControl];
}

#pragma mark -
#pragma mark TableView DataSource/Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    id datasource = (self.segmentedControl.selectedSegmentIndex == kBookmarksIndex) ? self.bookmarkDataSource : self.contactDataSource;
    return [datasource numberOfResultTypes];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    
    //ask delegate if it has a title and if section is non-empty. If both succeed, set title 
    //of section
    if (self.segmentedControl.selectedSegmentIndex == kBookmarksIndex) {
        if ([self.bookmarkDataSource numberOfResultsInSection:section] > 0) {
            title = [self.bookmarkDataSource titleOfResultTypeForSection:section];
        }
    }
    else
    {
        title = [self.contactDataSource titleOfResultTypeForSection:section];
    }

    return title;
}

//returns number of bookmarks dependent on which list user is currently looking at
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id datasource = (self.segmentedControl.selectedSegmentIndex == kBookmarksIndex) ? self.bookmarkDataSource : self.contactDataSource;
    return [datasource numberOfResultsInSection:section];
}

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    id datasource = (self.segmentedControl.selectedSegmentIndex == kBookmarksIndex) ? self.bookmarkDataSource : self.contactDataSource;
    if ([datasource respondsToSelector:@selector(sectionTitles)]) {
        return [datasource sectionTitles];
    } 
    
    return nil;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *DefaultCellIdentifier = @"DefaultCell";    
    
    UITableViewCell *cell = nil;
    
    
    id<NamedGeometry> currentNamedGeometry = nil; 
    if(self.segmentedControl.selectedSegmentIndex == kBookmarksIndex)
    {
        currentNamedGeometry = (id<NamedGeometry>)[self.bookmarkDataSource resultForRowAtIndexPath:indexPath];
    }
    else
    {
        currentNamedGeometry = (id<NamedGeometry>)[self.contactDataSource resultForRowAtIndexPath:indexPath];
    }

        
    if ([currentNamedGeometry respondsToSelector:@selector(tableViewCellForTableView:)]) {
        cell = [currentNamedGeometry tableViewCellForTableView:tableView];  
    }
    /*Location isn't explicitly defining how to draw itself... Do our best to draw it here! */
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:DefaultCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
                                           reuseIdentifier:DefaultCellIdentifier];
        }
        
        cell.textLabel.text = currentNamedGeometry.name;
        if ([currentNamedGeometry respondsToSelector:@selector(icon)] && currentNamedGeometry.icon != nil) 
        {
            cell.imageView.image = currentNamedGeometry.icon;
        }
        if([currentNamedGeometry respondsToSelector:@selector(detail)] && currentNamedGeometry.detail != nil)
        {
            cell.detailTextLabel.text = currentNamedGeometry.detail;
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id datasource = (self.segmentedControl.selectedSegmentIndex == kBookmarksIndex) ? self.bookmarkDataSource : self.contactDataSource;
    id delegate = (self.segmentedControl.selectedSegmentIndex == kBookmarksIndex) ? self.bookmarkDelegate : self.contactDelegate;
    id<NamedGeometry> bookmark = (id<NamedGeometry>)[datasource resultForRowAtIndexPath:indexPath];
        
    if ([delegate respondsToSelector:@selector(viewController:didClickOnResult:)]) {
        [delegate viewController:self didClickOnResult:bookmark];
    }
}

#pragma mark Editing/Moving TableView Rows

//user should only be able to edit the bookmarks located under "My Bookmarks"
-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL canMoveRowsForList = NO;
    
    if(self.showContacts && self.segmentedControl.selectedSegmentIndex == kContactsIndex)
    {
        canMoveRowsForList = NO;
    }
    else
    {
        canMoveRowsForList = [self.bookmarkDataSource canMoveResultAtIndexPath:indexPath];
    }
        
    return canMoveRowsForList;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self tableView:tableView canMoveRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath 
{
    DrawableList *bookmarksList = [self.bookmarkDataSource listForSection:fromIndexPath.section];
    
    [bookmarksList moveItemAtIndex:fromIndexPath.row toIndex:toIndexPath.row];
    
}

-(void)tableView:(UITableView *)tableView 
	commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
	forRowAtIndexPath:(NSIndexPath *)indexPath
{
    DrawableList *bookmarksList = [self.bookmarkDataSource listForSection:indexPath.section];
    [bookmarksList removeItemAtIndex:indexPath.row];

    [self.bookmarkTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
                            withRowAnimation:UITableViewRowAnimationFade];  
    
    if ([bookmarksList numberOfItems] == 0) {
        [self doneEditing];
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if (sourceIndexPath.section != proposedDestinationIndexPath.section) {        
        return [NSIndexPath indexPathForRow:sourceIndexPath.row inSection:sourceIndexPath.section];     
    }
    
    return proposedDestinationIndexPath;
}

#pragma mark -
#pragma mark UI Button Actions
-(IBAction)segmentedControlChanged:(id)sender
{
    [self setupEditButton];
	
    //stop editing if editing is occurring
    [self.bookmarkTableView setEditing:NO animated:YES];
	
    //update title bar
    [self currentNavItem].title = (self.segmentedControl.selectedSegmentIndex == kBookmarksIndex) ? NSLocalizedString(@"Bookmarks", nil) :NSLocalizedString(@"Contacts", nil);

	
    [self.bookmarkTableView reloadData];
}

-(void)doneEditing
{
    [self.bookmarkTableView setEditing:NO animated:YES];
    
    [self setupEditButton];
}

-(void)editMode
{
    [self.bookmarkTableView setEditing:YES animated:YES];
    [self currentNavItem].rightBarButtonItem = self.doneButton;
    [self currentNavItem].leftBarButtonItem = nil;
}

#pragma mark -
#pragma mark Contacts Methods
- (void) addressBookChanged:(NSNotification *)note
{
    [self.bookmarkTableView reloadData];
}

-(NSString *)nameForRecord:(ABRecordRef)record
{
    NSString *firstName = (NSString *)CFBridgingRelease(ABRecordCopyValue(record, kABPersonFirstNameProperty));
    if (!firstName) {
        firstName = @"";
    }
    
    NSString *lastName = (NSString *)CFBridgingRelease(ABRecordCopyValue(record, kABPersonLastNameProperty));
    if(!lastName)
    {
        lastName = @"";
    }
    
    return [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    
}

#pragma -
#pragma Lazy Loads
-(ArcGISAppDelegate *)app
{
    if(_app == nil)
    {
        self.app = (ArcGISAppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return _app;
}

-(UIBarButtonItem *)doneButton
{
    if(_doneButton == nil)
    {
        //Create new bar button items for editing
        UIBarButtonItem *aDoneButton = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Done", nil) 
                                                                       style:UIBarButtonItemStylePlain target:self 
                                                                      action:@selector(doneEditing)];
        self.doneButton = aDoneButton;
    }
    
    return _doneButton;
}

-(UIBarButtonItem *)editButton
{
    if(_editButton == nil)
    {
        UIBarButtonItem *anEditButton = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Edit", nil) 
                                                                        style:UIBarButtonItemStylePlain target:self 
                                                                       action:@selector(editMode)];
        self.editButton = anEditButton;
    }
    
    return _editButton;
}

#pragma -
#pragma Ux Methods
-(void)setupSegmentedControl
{
    if (self.showContacts) {
        
        //if toolbar isn't in view, add it, and update tableview accordingly
        if (self.toolbar.superview == nil) {
            [self.view addSubview:self.toolbar];
            
            CGRect tableViewRect = self.bookmarkTableView.frame;
            tableViewRect.size.height -= self.toolbar.frame.size.height;
            self.bookmarkTableView.frame = tableViewRect;
        }
        
        //set titles of segmented controls
        [self.segmentedControl setTitle:NSLocalizedString(@"Bookmarks", nil) forSegmentAtIndex:kBookmarksIndex];
        [self.segmentedControl setTitle:NSLocalizedString(@"Contacts", nil) forSegmentAtIndex:kContactsIndex];
    }
    else
    {
        //remove toolbar and adjust tableview accordingly
        if (self.toolbar.superview != nil) {
            CGRect tableViewRect = self.bookmarkTableView.frame;
            tableViewRect.size.height += self.toolbar.frame.size.height;
            self.bookmarkTableView.frame = tableViewRect; 
            
            [self.toolbar removeFromSuperview];
        }
    }
}

-(BOOL)showEditButton
{
    BOOL showEdit = (self.segmentedControl.selectedSegmentIndex == kBookmarksIndex);
    
    for (int i = 0; i < [self.bookmarkDataSource numberOfResultTypes]; i++) {
        showEdit &= [self.bookmarkDataSource canMoveResultAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]] && ([self.bookmarkDataSource numberOfResultsInSection:i] > 0);
    }
    
    return showEdit;
}

-(void)setupEditButton
{
    //only show an edit button if there are editable bookmarks
    [self currentNavItem].rightBarButtonItem = ([self showEditButton] && 
                                              self.showContacts && 
                                              self.segmentedControl.selectedSegmentIndex == kBookmarksIndex) ? self.editButton : nil;
}

#pragma mark -
#pragma mark Memory Management

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return [self.app shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.segmentedControl = nil;
    self.bookmarkTableView = nil;
    self.toolbar = nil;
}




@end
