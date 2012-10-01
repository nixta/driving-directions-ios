//
//  LocationCalloutView.m
//  Map
//
//  Created by Scott Sirowy on 11/21/11.
/*
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

#import "LocationCalloutView.h"
#import "Location.h"
#import "ToggleSegmentedControl.h"

#define kAccessoryViewWidth 25.0
#define kOriginalCalloutWidth 230
#define kComponentMargin 5.0
#define kSegmentedControlGrayColor 75.0

@interface LocationCalloutView () 

@property (nonatomic, copy) NSString    *addressString;

-(CGFloat)heightOfAddressString;
-(void)setAccessoryButtonView;
-(void)centerAccessoryButtonView;

-(void)directMeHereButtonPressed:(id)sender;
-(void)locationStopChanged:(id)sender;

-(NSInteger)segmentIndexForLocationType:(LocationType)locationType;
-(LocationType)locationTypeForSegmentIndex:(NSInteger)index;

-(void)locationUpdatedAddress:(NSNotification *)n;

-(void)showAddress;

@end

@implementation LocationCalloutView

@synthesize locationLabel = _locationLabel;
@synthesize addressLabel = _addressLabel;
@synthesize hideButton = _hideButton;
@synthesize actionButton = _actionButton;
@synthesize accessoryButton = _accessoryButton;
@synthesize fullViewButton = _fullViewButton;
@synthesize stopSegmentedControl = _stopSegmentedControl;

@synthesize location = _location;

@synthesize addressString = _addressString;
@synthesize delegate = _delegate;

- (void)dealloc {
    
    
    

    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLocationUpdatedAddress object:self.location];
    self.location = nil;
    
    
}

-(id)initWithLocation:(Location *)location calloutType:(MapAppState)aType
{
    self = [super initWithFrame:CGRectMake(0, 0, kOriginalCalloutWidth,75) withReflectionSlope:0.9 startingX:150 useShadow:NO];
    if(self)
    {
        self.location = location;
        _calloutType = aType;
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(locationUpdatedAddress:) 
                                                     name:kLocationUpdatedAddress 
                                                   object:self.location];
        
        UILabel *locLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        locLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:17.0];
        locLabel.textAlignment = UITextAlignmentCenter;
        locLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        locLabel.textColor = [UIColor whiteColor];
        locLabel.backgroundColor = [UIColor clearColor];
        self.locationLabel = locLabel;
        
        UILabel *addrLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        addrLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
        addrLabel.textAlignment = UITextAlignmentCenter;
        addrLabel.numberOfLines = 3;
        addrLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        addrLabel.textColor = [UIColor whiteColor];
        addrLabel.backgroundColor = [UIColor clearColor];
        self.addressLabel = addrLabel;
        
//        UIButton *hideButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        hideButton.frame = CGRectMake(0, 0, 25, 25);
//        hideButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
//        [hideButton setImage:[UIImage imageNamed:@"hidepin.png"] forState:UIControlStateNormal];
//        [hideButton addTarget:self action:@selector(hidePinButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
//        self.hideButton = hideButton;
        
        UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        actionButton.frame = CGRectMake(0, 0, 25, 25);
        actionButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        [actionButton setImage:[UIImage imageNamed:@"ActionSheet.png"] forState:UIControlStateNormal];
        [actionButton addTarget:self action:@selector(actionSheetButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        self.actionButton = actionButton;
        
        
        NSArray *scArray = nil;
        SEL scSelector = nil;
        if(_calloutType == MapAppStateSimple)
        {
            scArray = [NSArray arrayWithObjects:@"Go here", nil];
            scSelector = @selector(directMeHereButtonPressed:);
        }
        else if(_calloutType == MapAppStatePlanning)
        {
            //scArray = [NSArray arrayWithObjects:@"Start", @"Transit", @"Destination", nil];
            //scArray = [NSArray arrayWithObjects:@"Start", @"Stop", @"Finish", nil];
            scArray = [NSArray arrayWithObjects:@"Start", @"Stop", @"Destination", nil];
            scSelector = @selector(locationStopChanged:);
        }
            
        ToggleSegmentedControl *sc = [[ToggleSegmentedControl alloc] initWithItems:scArray];
        sc.segmentedControlStyle = UISegmentedControlStyleBar;
        sc.tintColor = [UIColor colorWithRed:(kSegmentedControlGrayColor/255.0) 
                                       green:(kSegmentedControlGrayColor/255.0) 
                                        blue:(kSegmentedControlGrayColor/255.0) 
                                       alpha:1.0];
        sc.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        
        sc.selectedSegmentIndex = [self segmentIndexForLocationType:self.location.locationType];
        
        [sc addTarget:self action:scSelector forControlEvents:UIControlEventValueChanged];
        self.stopSegmentedControl = sc;
        
        
        if ([self.location respondsToSelector:@selector(name)] && self.location.name != nil) {
            self.locationLabel.text = self.location.name;
        }
        else
        {
            self.locationLabel.text = NSLocalizedString(@"Location", nil);
        }
        
        if ([self.location hasAddress]) {
            [self showAddress];
        }
        else
        {
            //have location go get it's address
            self.location.delegate = self;
            [self.location updateAddress];
        }
        
    }
    return self;
}

-(id)initWithLocation:(Location *)location
{
    return [self initWithLocation:location calloutType:MapAppStateSimple];
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithLocation:nil];
}

#pragma mark -
#pragma mark Custom Setters
-(void)setLocation:(Location *)location
{
    if (_location == location)
        return;
    
    //remove observer from location
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLocationUpdatedAddress object:self.location];
    
    _location = location;
    
    //add observer for new location
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationUpdatedAddress:) name:kLocationUpdatedAddress object:self.location];
}

#pragma mark -
#pragma mark Button Interaction
-(IBAction)actionSheetButtonTapped:(id)sender
{
    if([self.delegate respondsToSelector:@selector(locationCalloutView:actionSheetButtonTappedForLocation:)])
    {
        [self.delegate locationCalloutView:self actionSheetButtonTappedForLocation:self.location];
    }
}

-(IBAction)hidePinButtonTapped:(id)sender
{
    if([self.delegate respondsToSelector:@selector(locationCalloutView:hidePinButtonTappedForLocation:)])
    {
        [self.delegate locationCalloutView:self hidePinButtonTappedForLocation:self.location];
    }
}

-(IBAction)accessoryButtonTapped:(id)sender
{
    if([self.delegate respondsToSelector:@selector(locationCalloutView:accessoryButtonTappedForLocation:)])
    {
        [self.delegate locationCalloutView:self accessoryButtonTappedForLocation:self.location];
    }
}

-(void)directMeHereButtonPressed:(id)sender
{
    if([self.delegate respondsToSelector:@selector(locationCalloutView:directToLocation:)])
    {
        [self.delegate locationCalloutView:self directToLocation:self.location];
    }
}

-(void)locationStopChanged:(id)sender
{
    if([self.delegate respondsToSelector:@selector(locationCalloutView:wouldLikeToChangeLocation:toType:)])
    {
        LocationType changeToType;
        
        if ([self segmentIndexForLocationType:self.location.locationType] == self.stopSegmentedControl.selectedSegmentIndex) {
            changeToType = LocationTypeNone;
            self.stopSegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment;
        }
        else
        {
            changeToType = [self locationTypeForSegmentIndex:self.stopSegmentedControl.selectedSegmentIndex];
        }
        
        [self.delegate locationCalloutView:self wouldLikeToChangeLocation:self.location toType:changeToType];
    }
}

#pragma mark -
#pragma mark Public Methods
-(void)showAccessoryView:(BOOL)show
{
    if (show == _isShowingAccessoryView)
        return;
    
    _isShowingAccessoryView = show;
    
    if (_isShowingAccessoryView) {
        [self addSubview:self.accessoryButton];
        [self setAccessoryButtonView];
    } 
    else {
        if (self.accessoryButton.superview != nil) {
            [self.accessoryButton removeFromSuperview];
            
            //Realign view so accessory button not needed
            CGRect viewRect = self.frame;
            viewRect.size.width -= kAccessoryViewWidth;   
            self.frame = viewRect;
            [self setNeedsDisplay];
        }
    }
    
    self.fullViewButton.userInteractionEnabled = _isShowingAccessoryView;
}

-(void)showHideButton:(BOOL)show
{
    self.hideButton.hidden = !show;
}

//Show the accessory button centered in height, and to the right of the address/location.
-(void)setAccessoryButtonView
{
    if (!_isShowingAccessoryView) {
        return;
    }
    
    [self centerAccessoryButtonView];
    
    //Realign view so accessory button fits in view
    CGRect viewRect = self.frame;
    viewRect.size.width += kAccessoryViewWidth;   //seemed to work well aethetically.
    self.frame = viewRect;
    [self setNeedsDisplay];
}

-(void)centerAccessoryButtonView
{
    if (!_isShowingAccessoryView) {
        return;
    }
    
    //we don't really have a toolbar, but we are sort of mimicing one
    CGFloat fauxToolbarHeight = self.locationLabel.frame.size.height + 2;
    
    CGFloat height = self.frame.size.height - fauxToolbarHeight;
    
    CGRect accessoryRect = self.accessoryButton.frame;
    accessoryRect.origin.y = (height/2 - accessoryRect.size.height/2) + fauxToolbarHeight;
    self.accessoryButton.frame = accessoryRect;
}


#pragma mark -
#pragma mark Adding an accessory button
-(UIButton *)accessoryButton
{
    if(_accessoryButton == nil)
    {
        UIButton *customButton = [UIButton buttonWithType:UIButtonTypeCustom]; 
        customButton.frame = CGRectMake(self.frame.size.width - 5, 0, kAccessoryViewWidth, kAccessoryViewWidth);
        customButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        
        [customButton setImage:[UIImage imageNamed:@"WhiteChevron.png"] forState:UIControlStateNormal];
        [customButton addTarget:self action:@selector(accessoryButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        self.accessoryButton = customButton;
    }
    
    return _accessoryButton;
}

-(UIButton *)fullViewButton
{
    if(_fullViewButton == nil)
    {
        UIButton *customButton = [UIButton buttonWithType:UIButtonTypeCustom];
        customButton.backgroundColor = [UIColor clearColor];
        customButton.userInteractionEnabled = NO;
        
        CGFloat yLocation = self.locationLabel.frame.origin.y + self.locationLabel.frame.size.height + 5;
        customButton.frame = CGRectMake(0, yLocation, self.bounds.size.width, self.bounds.size.height - yLocation);
        customButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [customButton addTarget:self action:@selector(accessoryButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        self.fullViewButton = customButton;
    }
    
    return _fullViewButton;
}

#pragma mark -
#pragma mark Location Delegate
-(void)locationUpdatedAddress:(NSNotification *)n
{
    [self showAddress];
}

#pragma mark -
#pragma mark Drawing Methods
-(void)layoutSubviews
{
    self.backgroundColor = [UIColor clearColor];
    
    CGRect contentRect = [self calculateContentRect:self.bounds];
    
    CGRect hideButtonRect = self.hideButton.frame;
    if (self.hideButton.superview == nil) {
        hideButtonRect.origin = CGPointMake(contentRect.origin.x + 5, contentRect.origin.y + 5);
        self.hideButton.frame = hideButtonRect;
        
        [self addSubview:self.hideButton];
    }
    
    CGRect actionButtonRect = self.actionButton.frame;
    if (self.actionButton.superview == nil) {
        actionButtonRect.origin = CGPointMake(contentRect.size.width - actionButtonRect.size.width, contentRect.origin.y + 3);
        self.actionButton.frame = actionButtonRect;
        
        [self addSubview:self.actionButton];
    }
    
    if (self.locationLabel.superview == nil) {
        CGFloat locLabelXOrigin = hideButtonRect.origin.x + hideButtonRect.size.width;
        CGFloat locLabelWidth = actionButtonRect.origin.x - locLabelXOrigin;
        self.locationLabel.frame = CGRectMake(locLabelXOrigin, contentRect.origin.y + 3, locLabelWidth, 24);
        [self addSubview:self.locationLabel];
    }
    
    if (self.stopSegmentedControl.superview == nil) {
        //add subview first here because control doesn't have a height/width yet
        [self addSubview:self.stopSegmentedControl];
        
        //then change frame in place
        CGRect stopSegmentedControlRect = self.stopSegmentedControl.frame;
        stopSegmentedControlRect.size.width = 210;
        CGFloat yOrigin = contentRect.size.height - stopSegmentedControlRect.size.height - kComponentMargin;
        CGFloat xOrigin = (contentRect.size.width - stopSegmentedControlRect.size.width)/2;
        stopSegmentedControlRect.origin = CGPointMake(xOrigin, yOrigin);
        self.stopSegmentedControl.frame = stopSegmentedControlRect;
    }
    
    //if we now have an address, show above lat/long information
    if ([self.location hasAddress] && self.location.addressString != nil) {
        if (self.addressLabel.superview == nil) {
            //change the height of address label
            CGRect addressLabelRect = self.addressLabel.frame;
            addressLabelRect.size = CGSizeMake(contentRect.size.width, [self heightOfAddressString]);
            addressLabelRect.origin = CGPointMake(contentRect.origin.x, self.hideButton.frame.origin.y + self.hideButton.frame.size.height);
            self.addressLabel.frame = addressLabelRect;
            
            [self addSubview:self.addressLabel];
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


#pragma mark -
#pragma mark Private Methods
-(void)showAddress
{
    if (![self.location hasAddress])
        return;
    
    if (_showingAddress)
        return;
    
    self.addressLabel.text = self.location.addressString;
    
    //when we aren't routing we need to account for the height we originally give the 
    //callout and subtract
    CGFloat segmentedControlOffset = (_calloutType == MapAppStateRoute) ? 30 : 0;
    
    CGRect myFrame = self.frame;
    myFrame.size.height += ([self heightOfAddressString] - segmentedControlOffset);
    self.frame = myFrame;
    
    _showingAddress = YES;
    
    [self setNeedsDisplay]; 
}

-(CGFloat)heightOfAddressString
{
    CGRect contentRect = [self calculateContentRect:self.bounds];
    CGSize labelConstraint = CGSizeMake(contentRect.size.width, 20000.0f);
    
    CGSize newTitleSize = [self.addressLabel.text 
                           sizeWithFont:self.addressLabel.font 
                           constrainedToSize:labelConstraint 
                           lineBreakMode:UILineBreakModeWordWrap];
    
    return newTitleSize.height + kComponentMargin;
}

//returns an integer for the location type of locatin
-(NSInteger)segmentIndexForLocationType:(LocationType)locationType
{
    NSInteger toReturn;
    switch (locationType) {
        case LocationTypeNone:
            toReturn = UISegmentedControlNoSegment;
            break;
        case LocationTypeStartLocation:
            toReturn = 0;
            break;
        case LocationTypeTransitLocation:
            toReturn = 1;
            break;
        case LocationTypeDestinationLocation:
            toReturn = 2;
            break;
        default:
            break;
    }

    return toReturn;
}

-(LocationType)locationTypeForSegmentIndex:(NSInteger)index
{
    LocationType toReturn = LocationTypeNone;
    switch (index) {
        case UISegmentedControlNoSegment:
            toReturn = LocationTypeNone;
            break;
        case 0:   //Start
            toReturn = LocationTypeStartLocation;
            break;
        case 1:
            toReturn = LocationTypeTransitLocation;
            break;
        case 2:
            toReturn = LocationTypeDestinationLocation;
            break;
        default:
            break;
    }
    
    return toReturn;
    
}

@end
