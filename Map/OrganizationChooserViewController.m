//
//  OrganizationChooserViewController.m
//  Map
//
//  Created by Scott Sirowy on 10/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "OrganizationChooserViewController.h"
#import "Organization.h"
#import "UIColor+Additions.h"

@interface OrganizationChooserViewController ()

@property (nonatomic, retain) NSArray *organizations;

@end

@implementation OrganizationChooserViewController

@synthesize tableView = _tableView;
@synthesize finishButton = _finishButton;

@synthesize organizations = _organizations;
@synthesize delegate = _delegate;
@synthesize selectedIndex = _selectedIndex;

-(void)dealloc
{
    self.tableView = nil;
    self.finishButton = nil;
    
    self.organizations = nil;
    
    [super dealloc];
}

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
    
    self.finishButton.enabled = (self.organizations.count > 0);
    
    //self.view.backgroundColor = [UIColor offWhiteColor];
    //self.tableView.backgroundColor = [UIColor offWhiteColor];
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
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIDString] autorelease];
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
