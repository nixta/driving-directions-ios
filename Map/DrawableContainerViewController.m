//
//  SearchPageViewController.m
//  Map
//
//  Created by Scott Sirowy on 9/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DrawableContainerViewController.h"
#import "MapAppDelegate.h"
#import "Location.h"

#define kKeyboardHeight 216

@interface DrawableContainerViewController () 

@property (nonatomic, assign) ArcGISAppDelegate *app;

-(void)setupUxForToolbar;
-(UIView *)selectedBackgroundViewWithFrame:(CGRect)frame;

@end

@implementation DrawableContainerViewController

@synthesize tableView = _tableView;
@synthesize toolbar = _toolbar;
@synthesize showToolbar = _showToolbar;
@synthesize delegate = _delegate;
@synthesize datasource = _datasource;
@synthesize highlightCurrentIndex = _highlightCurrentIndex;

@synthesize app = _app;

-(void)dealloc
{
    self.tableView = nil;
    self.toolbar = nil;
    
    [super dealloc];
}

-(id)initWithToolbar:(BOOL)showToolbar
{
    self = [super initWithNibName:@"DrawableContainerViewController" bundle:nil];
    if (self) {
        _showToolbar = showToolbar;
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _showToolbar = NO;        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.showToolbar) {
        [self setupUxForToolbar];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    self.tableView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [self.app shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

#pragma -
#pragma Lazy Loads
-(ArcGISAppDelegate *)app
{
    if(_app == nil)
        self.app = (MapAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    return _app;
}

-(UIToolbar *)toolbar
{
    if(_toolbar == nil)
    {
        UIToolbar *tb = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
        tb.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        tb.barStyle = UIBarStyleBlackOpaque;
        self.toolbar = tb;
        [tb release];
    }
    
    return _toolbar;
}

#pragma mark -
#pragma mark Toolbar setup
-(void)setupUxForToolbar
{
    [self.view addSubview:self.toolbar];
    
    CGRect tvRect = self.tableView.frame;
    tvRect.origin.y += self.toolbar.frame.size.height;
    tvRect.size.height -= self.toolbar.frame.size.height;
}

#pragma mark -
#pragma mark Other Ux Stuff
-(UIView *)selectedBackgroundViewWithFrame:(CGRect)frame
{
    UIView *v = [[UIView alloc] initWithFrame:frame];
    v.backgroundColor = [UIColor greenColor];
    return [v autorelease];
}


#pragma mark -
#pragma mark Public Methods
/*Call to update the status of the search results */
-(void)refineSearchResults
{
    [self.tableView reloadData];
}

//Call to min/max accounting for a keyboard
-(void)minimize
{
    //need to make the table view only as high as the keyboard
    //is, otherwise some elements might not be able to be seen
    if(!_tableViewMinimized)
    {
        CGRect tvRect = self.tableView.frame;
        tvRect.size.height -= kKeyboardHeight;
        self.tableView.frame = tvRect;
        
        _tableViewMinimized = YES;
    }
}

-(void)maximize
{
    //need to make the table view full size
    if(_tableViewMinimized)
    {
        CGRect tvRect = self.tableView.frame;
        tvRect.size.height += kKeyboardHeight;
        self.tableView.frame = tvRect;
        
        _tableViewMinimized = NO;
    }
}

#pragma mark -
#pragma mark TableView Data Source
/*Legend Model dictates all of the information to be presented in the tableview */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return [self.datasource numberOfResultTypes];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{    
    return [self.datasource numberOfResultsInSection:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.datasource titleOfResultTypeForSection:section];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
    static NSString *DefaultCellIdentifier = @"DefaultCell";
    
    id<TableViewDrawable> currentResult = [self.datasource resultForRowAtIndexPath:indexPath];
    
    UITableViewCell *cell = nil;
    
    if ([currentResult respondsToSelector:@selector(tableViewCellForTableView:)]) {
        cell = [currentResult tableViewCellForTableView:tableView];  
    }
    /*Doesn't explicitly defining how to draw itself... Do our best to draw it here! */
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:DefaultCellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
                                           reuseIdentifier:DefaultCellIdentifier] autorelease];
        }
        
        cell.textLabel.text = currentResult.name;
        if ([currentResult respondsToSelector:@selector(icon)] && currentResult.icon != nil) 
        {
            cell.imageView.image = currentResult.icon;
        }
        else
        {
            cell.imageView.image = nil;   
        }
        
        if([currentResult respondsToSelector:@selector(detail)] && currentResult.detail != nil)
        {
            cell.detailTextLabel.text = currentResult.detail;
        }
        else
        {
            cell.detailTextLabel.text = nil;
        }
    }
        
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;
}

#pragma mark -
#pragma mark TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id<TableViewDrawable> result = [self.datasource resultForRowAtIndexPath:indexPath];
    
    if ([self.delegate respondsToSelector:@selector(viewController:didClickOnResult:)]) {
        [self.delegate viewController:self didClickOnResult:result];
    }
}

@end
