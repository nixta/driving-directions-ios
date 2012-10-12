/*
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

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


@end
