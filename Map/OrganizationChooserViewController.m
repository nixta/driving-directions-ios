//
//  OrganizationChooserViewController.m
//  Map
//
//  Created by Scott Sirowy on 10/31/11.
/*
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

#import "OrganizationChooserViewController.h"
#import "Organization.h"
#import "UIColor+Additions.h"

@interface OrganizationChooserViewController ()

@property (nonatomic, strong) NSArray *organizations;

@end

@implementation OrganizationChooserViewController

-(id)initWithOrganizations:(NSArray *)organizations
{
    self = [super initWithNibName:@"OrganizationChooserViewController" bundle:nil];
    if(self)
    {
        self.organizations = organizations;
        _selectedIndex = 0;
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self initWithOrganizations:nil];
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
    
    // Hides the status bar.
    //[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    self.finishButton.enabled = (self.organizations.count > 0);
    self.view.hidden = YES;        
}

- (void)requestTimerReady {
    [self.delegate organizationChooser:self didChooseOrganization:[self.organizations objectAtIndex:0]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.organizations.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIDString = @"OrganizationID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIDString];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIDString];
    }
    
    Organization *org = [self.organizations objectAtIndex:indexPath.row];
    
    cell.textLabel.text = org.name;
    cell.imageView.image = org.icon;
    cell.accessoryType = (_selectedIndex == indexPath.row) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == _selectedIndex)
        return;
    
    _selectedIndex = indexPath.row;
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark Button Interaction
-(IBAction)finishButtonPressed:(id)sender
{
    if([self.delegate respondsToSelector:@selector(organizationChooser:didChooseOrganization:)])
    {
        [self.delegate organizationChooser:self didChooseOrganization:[self.organizations objectAtIndex:_selectedIndex]];
    }
}

@end
