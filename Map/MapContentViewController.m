
//
//  MapContentViewController.m
//  Map
//
//  Created by Scott Sirowy on 8/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MapContentViewController.h"
#import "MapAppDelegate.h"
#import "MapAppSettings.h"
#import "Organization.h"
#import "MapLegendViewController.h"
#import "UIColor+Additions.h"
#import "UIToolbar+MapAdditions.h"

#import "BasemapsViewController.h"
#import "BasemapsTableViewCell.h"

#import "SettingsViewController.h"

#import "SectionHeaderView.h"
#import "SectionInfo.h"

@interface MapContentViewController () 

@property (nonatomic, retain) BasemapsViewController    *basemapsVC;
@property (nonatomic, retain) BasemapsTableViewCell     *basemapsTableViewCell;
@property (nonatomic, retain) SettingsViewController    *settingsVC;
@property (nonatomic, retain) NSMutableArray            *layersArray;
@property (nonatomic, retain) UIView                    *waitingView;
@property (nonatomic, retain) UIActivityIndicatorView   *activityIndicator;
@property (nonatomic, assign) MapAppSettings            *appSettings;

-(NSUInteger)adjustedIndexForSection:(NSUInteger)section;
-(void)createLegendSections;
-(void)generateLegend;

@end

#define kBasemapCellHeight 190

static NSUInteger kBasemapSection = 0;

@implementation MapContentViewController

@synthesize tableView = _tableView;
@synthesize navBar = _navBar;
@synthesize navItem = _navItem;
@synthesize settingsView = _settingsView;
@synthesize signInLabel = _signInLabel;

@synthesize mapButton = _mapButton;
@synthesize settingsButton = _settingsButton;

@synthesize changeBasemapDelegate = _changeBasemapDelegate;

//private properties
@synthesize basemapsVC = _basemapsVC;
@synthesize basemapsTableViewCell = _basemapsTableViewCell;
@synthesize settingsVC = _settingsVC;
@synthesize layersArray = _layersArray;
@synthesize waitingView = _waitingView;
@synthesize activityIndicator = _activityIndicator;
@synthesize appSettings = _appSettings;

#pragma mark -
#pragma mark Init/Dealloc Methods

-(void)dealloc
{
    self.tableView = nil;
    self.navBar    = nil;
    self.navItem   = nil;    
    self.settingsView = nil;
    self.signInLabel = nil;
    
    self.mapButton = nil;
    self.settingsButton = nil;
    
    self.settingsVC = nil;
    self.basemapsVC = nil;
    self.basemapsTableViewCell = nil;
    self.layersArray = nil;
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

-(id)initWithMapLayerViews:(NSDictionary *)mapLayerViews
{
    self = [self initWithNibName:@"MapContentViewController" bundle:nil];
    if (self) {
        _mapLayerViews = mapLayerViews;
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
/*Message passed to indicate basemap has successfully been changed somewhere in the app */
-(void)successfullyChangedBasemap
{
    [self.waitingView removeFromSuperview];
    
    //inform basemaps it can change state
    [self.basemapsVC successfullyChangedBasemap];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor offWhiteColor];
    
    //Configure tableview
    self.tableView.backgroundColor = [UIColor offWhiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //has to be here for iOS 5
    self.tableView.sectionHeaderHeight = 44.0;
    
    self.settingsView.backgroundColor = [UIColor blackColor];
    self.signInLabel.text = [NSString stringWithFormat:@"Signed in with %@", self.appSettings.organization.name];
    
    if (!self.appSettings.legend.finishedDownloading) {
        [self generateLegend];
    }
    else
    {
        [self createLegendSections];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.leftBarButtonItem = self.mapButton;
    self.navigationItem.rightBarButtonItem = self.settingsButton;
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    self.tableView = nil;
    self.navBar    = nil;
    self.navItem   = nil;
    self.mapButton = nil;
    self.settingsButton = nil;
    self.settingsView = nil;
    self.signInLabel = nil;
    
    self.basemapsVC = nil;
    self.basemapsTableViewCell = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    ArcGISAppDelegate *app = [[UIApplication sharedApplication] delegate];
    return ([app shouldAutorotateToInterfaceOrientation:interfaceOrientation]);
}

#pragma mark -
#pragma mark Lazy Loads
-(MapAppSettings *)appSettings
{
    MapAppDelegate *app = (MapAppDelegate *)[[UIApplication sharedApplication] delegate];
    return (MapAppSettings *)app.appSettings;
}

-(BasemapsViewController *)basemapsVC
{
    if(_basemapsVC == nil)
    {
        BasemapsViewController *bmvc = [[BasemapsViewController alloc] initWithNibName:@"BasemapsViewController" bundle:nil];
        bmvc.delegate = self;
        self.basemapsVC = bmvc;
        [bmvc release];
    }
    
    return _basemapsVC;
}

-(UIBarButtonItem *)mapButton
{
    if(_mapButton == nil)
    {
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Map", nil) 
                                                                style:UIBarButtonItemStyleBordered 
                                                               target:self 
                                                               action:@selector(mapButtonPressed:)];
        self.mapButton = bbi;
        [bbi release];
    }
    
    return _mapButton;
}

-(UIBarButtonItem *)settingsButton
{
    if(_settingsButton == nil)
    {
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings.png"] 
                                                                style:UIBarButtonItemStyleBordered 
                                                               target:self 
                                                               action:@selector(settingsButtonTapped:)];
        self.settingsButton = bbi;
        [bbi release];
    }
    
    return _settingsButton;
}

-(UIView *)waitingView
{
    if(_waitingView == nil)
    {
        //waiting view is a somewhat translucent black screen
        UIView *view = [[UIView alloc]initWithFrame:self.navigationController.view.bounds];
        view.userInteractionEnabled = YES;
        view.opaque = NO;
        view.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:.65];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        //The black screen includes a moving activity indicator
        self.activityIndicator = [[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge]autorelease];
        self.activityIndicator.center = CGPointMake(view.bounds.size.width/2, view.bounds.size.height/2);
        self.activityIndicator.userInteractionEnabled = NO;
        [self.activityIndicator stopAnimating];
        
        [view addSubview:self.activityIndicator];
        
        self.waitingView = view;
        [view release];
    }
    
    return _waitingView;
}

#pragma mark -
#pragma mark Button Interaction etc.

-(void)mapButtonPressed:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

-(IBAction)settingsButtonTapped:(id)sender
{    
    SettingsViewController *svc = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
    svc.appSettings = self.appSettings;
    svc.view.frame = self.tableView.frame;
    self.settingsVC = svc;
    [svc release]; 
    
    //[self.view addSubview:self.settingsVC.view];
    [self.navigationController pushViewController:self.settingsVC animated:YES];
}

#pragma mark -
#pragma mark TableView Data Source
-(NSUInteger)adjustedIndexForSection:(NSUInteger)section
{
    if (section == 0) {
        return section;
    }
    
    return section -1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    //Basemap Section + Layers Section
    return 1 + [self.layersArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{    
    if (section == kBasemapSection) {
        return 1;
    }
    else
    {
        SectionInfo *sectionInfo = [self.layersArray objectAtIndex:[self adjustedIndexForSection:section]];
        NSInteger numLegendEntries = [sectionInfo numberOfEntries];
        
        return sectionInfo.open ? numLegendEntries : 0;
    }
}

-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section{

    if (section == kBasemapSection)
        return nil;
           
    SectionInfo *sectionInfo = [self.layersArray objectAtIndex:[self adjustedIndexForSection:section]];
    if (!sectionInfo.headerView) {
        sectionInfo.headerView = [[[SectionHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.bounds.size.width, 44) 
                                                                     title:sectionInfo.title
                                                                   section:section 
                                                                  delegate:self] autorelease];
    }
    
	return sectionInfo.headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == kBasemapSection)
        return 0;
    
    SectionInfo *sectionInfo = [self.layersArray objectAtIndex:[self adjustedIndexForSection:section]];
    if (!sectionInfo.headerView) {
        sectionInfo.headerView = [[[SectionHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.bounds.size.width, 44) 
                                                                     title:sectionInfo.title
                                                                   section:section 
                                                                  delegate:self] autorelease];
    }
    
	return sectionInfo.headerView.frame.size.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    CGFloat cellHeight;
    
    if(indexPath.section == kBasemapSection)
    {
        cellHeight = kBasemapCellHeight;
    }
	else 
    {
        cellHeight = 44.0;
    }
    
    return cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *LegendCellIdentifier = @"LegendCell";
    static NSString *BasemapCellIdentifier = @"BasemapCell";
     
    UITableViewCell *cell;
    
    if (indexPath.section == kBasemapSection) {
        cell = [tableView dequeueReusableCellWithIdentifier:BasemapCellIdentifier];
        if (cell == nil)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"BasemapsTableViewCell" owner:self options:nil];
            for (id object in topLevelObjects)
            {
                if ([object isKindOfClass:[UITableViewCell class]])
                {
                    cell = object;
                    break;
                }
            }
            
            //for retainment purposes
            self.basemapsTableViewCell = (BasemapsTableViewCell *)cell;
            
            //add a new view controller's view to cell. This media controller will control behavior for the cell
            [self.basemapsTableViewCell.view addSubview:self.basemapsVC.view];
        }
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:LegendCellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LegendCellIdentifier] autorelease];
        }
        
        //offset section by basemap section
        SectionInfo *si = [self.layersArray objectAtIndex:indexPath.section -1 ];
        LegendElement *le = [si elementAtIndex:indexPath.row];
        
        if (le.swatch || le.title) {
            cell.imageView.image = le.swatch;
            cell.textLabel.text = le.title;
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            cell.textLabel.textAlignment = UITextAlignmentLeft;
        }
        else
        {
            cell.imageView.image = nil;
            cell.textLabel.text = NSLocalizedString(@"No legend information is available", nil);
            cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Oblique" size:[UIFont systemFontSize]];
            cell.textLabel.textAlignment = UITextAlignmentCenter;
        }
        
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


#pragma mark -
#pragma mark TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark Section header delegate

-(void)sectionHeaderView:(SectionHeaderView*)sectionHeaderView sectionOpened:(NSInteger)sectionOpened {
	
	SectionInfo *sectionInfo = [self.layersArray objectAtIndex:[self adjustedIndexForSection:sectionOpened]];	
	sectionInfo.open = YES;
    
    /*
     Create an array containing the index paths of the rows to insert: These correspond to the rows for each quotation in the current section.
     */
    NSInteger countOfRowsToInsert = [sectionInfo numberOfEntries];
    NSMutableArray *indexPathsToInsert = [[[NSMutableArray alloc] init] autorelease];
    for (NSInteger i = 0; i < countOfRowsToInsert; i++) {
        [indexPathsToInsert addObject:[NSIndexPath indexPathForRow:i inSection:sectionOpened]];
    }
        
    // Apply the updates.
    [self.tableView insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:UITableViewRowAnimationNone];
}


-(void)sectionHeaderView:(SectionHeaderView*)sectionHeaderView sectionClosed:(NSInteger)sectionClosed {
    
    /*
     Create an array of the index paths of the rows in the section that was closed, then delete those rows from the table view.
     */
	SectionInfo *sectionInfo = [self.layersArray objectAtIndex:[self adjustedIndexForSection:sectionClosed]];
	
    sectionInfo.open = NO;
    NSInteger countOfRowsToDelete = [self.tableView numberOfRowsInSection:sectionClosed];
    
    if (countOfRowsToDelete > 0) {
        NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < countOfRowsToDelete; i++) {
            [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:sectionClosed]];
        }
        [self.tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationNone];
        [indexPathsToDelete release];
    }
}

-(void)sectionHeaderView:(SectionHeaderView *)sectionHeaderView toggledUISwitch:(UISwitch *)aSwitch
{
    UIView *layer = (UIView *)[_mapLayerViews objectForKey:sectionHeaderView.titleLabel.text];
    layer.hidden = !layer.hidden;
    
    
    if (layer.hidden && sectionHeaderView.disclosureButton.selected) {
        [sectionHeaderView toggleOpenWithUserAction:YES];
    }
    
    //rebuild legend!
    [self generateLegend];
}

#pragma mark -
#pragma mark ChangeBasemaps Delegate
-(void)basemapsViewController:(BasemapsViewController *)bmvc wantsToChangeToNewBasemap:(BasemapInfo *)basemap
{    
    _waitingForBasemapToChange = YES;
    
    //pass up the chain
    if([self.changeBasemapDelegate respondsToSelector:@selector(basemapsViewController:wantsToChangeToNewBasemap:)])
    {
        [self.changeBasemapDelegate basemapsViewController:bmvc wantsToChangeToNewBasemap:basemap];
    }
    
    [self.navigationController.view addSubview:self.waitingView];
    [self.activityIndicator startAnimating];
}

#pragma mark -
#pragma mark LegendDelegate
-(void)legendFinishedDownloading:(Legend *)legend
{
    [self createLegendSections];
}

#pragma mark -
#pragma mark Legend Creation
-(void)generateLegend
{
    MapAppDelegate *app = (MapAppDelegate *)[[UIApplication sharedApplication] delegate];
    Legend *legend = ((MapAppSettings *)app.appSettings).legend;
    legend.delegate = self;
    [legend buildLegend];
}

-(void)createLegendSections
{
    MapAppDelegate *app = (MapAppDelegate *)[[UIApplication sharedApplication] delegate];
    Legend *legend = ((MapAppSettings *)app.appSettings).legend;
    
    //Initialize Sections for map legend/content/etc
    if(_layersArray == nil)
    {
        NSUInteger numLayers = [legend numberOfLayers];
        
        self.layersArray = [NSMutableArray arrayWithCapacity:numLayers];
        for (int i = 0; i < numLayers; i++) {
            SectionInfo *si = [[SectionInfo alloc] init];
            si.legendLayer = [legend legendLayerAtIndex:i];
            [self.layersArray addObject:si];
            [si release];
        }
    } 
    
    [self.tableView reloadData];
}

@end
