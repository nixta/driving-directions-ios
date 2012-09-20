/*
 MapLegendViewController.m
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

#import "MapLegendViewController.h"
#import "MapAppDelegate.h"
#import "UIColor+Additions.h"
//#import "Legend.h"


#define kSeparatorCellHeight 5.0
#define kFullLegendCellHeight 36.0
#define kLightGraySeparatorTag 1000
#define kDarkGraySeparatorTag 1001
#define kNoLegendTag 5000

@interface MapLegendViewController () 

-(void)showActivityIndicator:(BOOL)show;

@end


@implementation MapLegendViewController

@synthesize tableView = _tableView;
@synthesize activityIndicatorView = _activityIndicatorView;
@synthesize activityIndicator = _activityIndicator;


#pragma mark -
#pragma mark Lazy Loads
-(UIView *)activityIndicatorView
{
    if(_activityIndicatorView == nil)
    {
        //activity indicator view is a somewhat translucent black screen
        self.activityIndicatorView = [[[UIView alloc]initWithFrame:self.view.bounds]autorelease];
        _activityIndicatorView.hidden = YES;
        _activityIndicatorView.userInteractionEnabled = YES;
        _activityIndicatorView.opaque = NO;
        _activityIndicatorView.backgroundColor = [UIColor clearColor];
        _activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        //The black screen includes a moving activity indicator
        self.activityIndicator = [[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge]autorelease];
        self.activityIndicator.center = CGPointMake(self.activityIndicatorView.bounds.size.width/2, self.activityIndicatorView.bounds.size.height/2);
        self.activityIndicator.userInteractionEnabled = NO;
        self.activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self.activityIndicator stopAnimating];
        [_activityIndicatorView addSubview:self.activityIndicator];
        
    }
    
    return _activityIndicatorView;
}

#pragma mark -
#pragma mark Apple View Stuff

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    /*Commented out for now 
    [self.view addSubview:self.activityIndicatorView];
    [self showActivityIndicator:YES];
     */
    
    self.view.backgroundColor = [UIColor offWhiteColor];
    
    // subscribe to layerVisibility Changes. Every time a layer's visibility changes,
    //we will instruct the legend model to regenerate itself at the appropriate time
    _legendNeedsToBeRegenerated = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(legendShouldBeRedrawn:)
                                                 name:@"LayerVisibilityChanged"
                                               object:nil];
    
#warning Commented Out. Will need something similar later
    /*
    //Susbcribe the map scale changes. Every time the map's scale change, instruct
    //the legend model to regenerate itself at the appropriate time
    AGSMapView *theMapView = _app.mainPageVC.mapPageVC.mapView;
    [theMapView addObserver:self forKeyPath:@"mapScale" options:NSKeyValueChangeReplacement context:nil];
     */
}

//Using viewWillAppear because for some reason, viewDidAppear does not want to be called
-(void)viewWillAppear:(BOOL)animated
{
    /*
    if(_legendNeedsToBeRegenerated)
    {
        [_app.currentMapSettings.legend buildLegend];
        _legendNeedsToBeRegenerated = NO;
        [self.tableView reloadData];
    }
     */
}

//overriding to ensure on iPad controller doesn't stretch out to fill screen.
//Don't need a separate Ipad-specific class to do this since this will never
//be called on an Iphone
-(CGSize)contentSizeForViewInPopover
{
    return CGSizeMake(320, 480);
}

-(void)generateLegend
{
    /*
    Legend *mapLegend = _app.currentMapSettings.legend;
    mapLegend.delegate = self;
    
    //instruct model to build legend. Delegate method will tell us when that is done
    [mapLegend buildLegend];
     */
}

#pragma mark -
#pragma mark Utility Methods
-(void)showActivityIndicator:(BOOL)show
{
	if (!show){
		[self.activityIndicator stopAnimating];
	}
	else {
		[self.activityIndicator startAnimating];
	}
	self.activityIndicatorView.hidden = !show;
}

//called when we get a notification for the event "LayerVisibilityChanged" OR 
//if the map scale changes
//Sets flag that will be handled at an appropriate time (e.g when the view appears)
-(void)legendShouldBeRedrawn:(id)sender
{
    _legendNeedsToBeRegenerated = YES;
}

#pragma mark -
#pragma mark Key Value Observing
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqual:@"mapScale"]) 
    {
        [self legendShouldBeRedrawn:nil];
    }  
}

#pragma mark -
#pragma mark LegendDelegate
/*
-(void)legendFinishedDownloading:(Legend *)legend
{
    [self showActivityIndicator:NO];
    
    if ([legend totalEntriesInLegend] == 0) {
        
        //if a no legend label already exists, skip
        UIView *label = [self.view viewWithTag:kNoLegendTag];
        if (label) 
            return;
        
        UILabel *failedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.view.frame.size.width, 25)];
        failedLabel.textAlignment = UITextAlignmentCenter;
        failedLabel.font = [UIFont fontWithName:@"Helvetica-Oblique" size:[UIFont systemFontSize]];
        failedLabel.text = NSLocalizedString(@"No legend information available", nil);
        failedLabel.backgroundColor = [UIColor clearColor];
        failedLabel.textColor = [UIColor darkGrayColor];
        failedLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        failedLabel.tag = kNoLegendTag;
        
        [self.view addSubview:failedLabel];
        [failedLabel release];
    }
    else {
        
        UIView *label = [self.view viewWithTag:kNoLegendTag];
        if (label) {
            [label removeFromSuperview];
        }
        
        [self.tableView reloadData];
    }
}
 */

#pragma mark -
#pragma mark TableView Data Source
/*Legend Model dictates all of the information to be presented in the tableview */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{    
    //return [_app.currentMapSettings.legend totalEntriesInLegend];
    return 1;
}

/*
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LegendElement *le = [_app.currentMapSettings.legend legendElementAtRow:indexPath.row];
    
    //if no title and no image, the legend element is acting as a separator
    if (le.title == nil && le.swatch == nil)
        return kSeparatorCellHeight;
    
    //give the title an empty string if its empty so it sizes correctly
    if (le.title == nil || [le.title length] == 0) {
        le.title = @"      ";
    }
    
    //Calculating the height of the cell based on the level at which the row is
    //being presented (lower levels have smaller font => smaller cell height needed)
    NSString *fontName = (le.level == 0) ? @"Helvetica-Bold" : @"Helvetica";
    UIFont *cellFont = [UIFont fontWithName:fontName size:(18.0 - le.level)];
    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
    CGSize labelSize = [le.title sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    
    return labelSize.height + 15;
}  */

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    /*static NSString *CellIdentifier = @"Cell";
    static NSString *SeparatorCellIdentifier = @"SeparatorCell";
    
    //The font of the cell is controlled by the level at which the cell is being displayed
    LegendElement *le = [_app.currentMapSettings.legend legendElementAtRow:indexPath.row];
    
    UITableViewCell *cell;
    //create a separator cell
    if(le.title == nil)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:SeparatorCellIdentifier];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SeparatorCellIdentifier] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            //can just create separator views on initialization
            UIView *lightGraySeparator = [[[UIView alloc] initWithFrame:CGRectMake(5, 2, self.view.frame.size.width -10, 1)] autorelease];
            lightGraySeparator.backgroundColor = [UIColor lightGrayColor];
            lightGraySeparator.autoresizingMask = UIViewAutoresizingFlexibleWidth | 
            UIViewAutoresizingFlexibleLeftMargin | 
            UIViewAutoresizingFlexibleRightMargin;
            lightGraySeparator.tag = kLightGraySeparatorTag;
            
            [cell.contentView addSubview:lightGraySeparator];
            
            UIView *darkGraySeparator = [[[UIView alloc] initWithFrame:CGRectMake(6, 3, self.view.frame.size.width -10, 1)] autorelease];
            darkGraySeparator.backgroundColor = [UIColor darkGrayColor];
            darkGraySeparator.autoresizingMask = UIViewAutoresizingFlexibleWidth | 
            UIViewAutoresizingFlexibleLeftMargin | 
            UIViewAutoresizingFlexibleRightMargin;
            darkGraySeparator.tag = kDarkGraySeparatorTag;
            
            [cell.contentView addSubview:darkGraySeparator];
        }
    }
    //create a "normal" populated cell
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.numberOfLines = 0;
        }
        
        NSString *fontName = (le.level == 0) ? @"Helvetica-Bold" : @"Helvetica";
        cell.textLabel.font = [UIFont fontWithName:fontName size:(18.0 - (0.75*le.level))];
        cell.textLabel.text = le.title;
        cell.imageView.image = le.swatch;
    }
	
    return cell;  */
    
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    

    cell.textLabel.text = @"Legend!";
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

#pragma mark -
#pragma mark TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    
    /*AGSMapView *theMapView = _app.mainPageVC.mapPageVC.mapView;
    [theMapView removeObserver:self forKeyPath:@"mapScale"];  */
    
    //remove observer
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:@"LayerVisibilityChanged" object:nil];
    
    //remove delegate on legend
    //_app.currentMapSettings.legend.delegate = nil;
    
    self.tableView = nil;
    self.activityIndicatorView = nil;
    self.activityIndicator = nil;
    
    [super dealloc];
}

@end
