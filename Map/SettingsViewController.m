//
//  SettingsViewController.m
//  Map
//
//  Created by Scott Sirowy on 9/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import "MapAppSettings.h"
#import "Organization.h"
#import "UIColor+Additions.h"
#import "OrganizationChooserViewController.h"
#import "MapAppDelegate.h"
#import "MapViewController.h"

#define kLoginSection 0
#define kSearchSection 1

@implementation SettingsViewController

@synthesize tableView = _tableView;
@synthesize appSettings = _appSettings;
@synthesize chooserVC = _chooserVC;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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

    self.view.backgroundColor = [UIColor offWhiteColor];
    self.tableView.backgroundColor = [UIColor offWhiteColor];
    
    self.navigationItem.title = NSLocalizedString(@"Settings", nil);
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    self.tableView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    //Needs to be redone! Just a skeleton
    NSString *title = nil;
    if (section == kLoginSection) {
        title =  @"Login Information";
    }
    else
    {
        title = @"Search Settings";
    }
    
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    //Needs to be redone! Just a skeleton
    if (indexPath.section == 0) {
        cell.textLabel.text = @"";
        
       
    }
    else
    {
        cell.textLabel.text = @"Clear Search History";
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MapAppDelegate *mad = (MapAppDelegate *)[[UIApplication sharedApplication] delegate];
    MapAppSettings *mas = (MapAppSettings *)mad.appSettings;
    
    if (indexPath.section == kLoginSection) {
        
        NSUInteger currentOrgIndex = [mad.testOrganizations indexOfObject:mas.organization];
        
        OrganizationChooserViewController *ocvc = [[OrganizationChooserViewController alloc] initWithOrganizations:mad.testOrganizations];
        self.chooserVC = ocvc;
        
        self.chooserVC.selectedIndex = currentOrgIndex;
        self.chooserVC.delegate = self;
        
        [self presentModalViewController:self.chooserVC animated:YES];
    }
    else if(indexPath.section == kSearchSection)
    {
        [mas clearRecentSearches];
        //Clear recent routes and search history
    }
}

-(void)organizationChooser:(OrganizationChooserViewController *)orgVC didChooseOrganization:(Organization *)organization
{
    //clearly a hack job... Whole thing is created for a demo... Remove immediately after!
    MapAppDelegate *mad = (MapAppDelegate *)[[UIApplication sharedApplication] delegate];
    MapViewController *mvc = (MapViewController *)mad.viewController;
    MapAppSettings *mas = (MapAppSettings *)mad.appSettings;

    NSUInteger currentOrgIndex = [mad.testOrganizations indexOfObject:mas.organization];
    
    //animate only if they picked same service!
    [self dismissModalViewControllerAnimated:(currentOrgIndex == orgVC.selectedIndex)];
    
    if (currentOrgIndex != orgVC.selectedIndex) {
        [self.navigationController popViewControllerAnimated:YES];
        [mvc showActivityIndicator:YES];
        
        [mvc organizationChooser:orgVC didChooseOrganization:organization];
    }
}

@end
