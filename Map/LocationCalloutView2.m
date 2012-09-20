//
//  LocationCalloutView.m
//  Map
//
//  Created by Scott Sirowy on 11/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LocationCalloutView2.h"
#import "LocationCalloutView.h"
#import "Location.h"

#define kAccessoryViewWidth 25.0
#define kOriginalCalloutWidth 230
#define kComponentMargin 5.0
#define kSegmentedControlGrayColor 75.0

@interface LocationCalloutView2 () 

@property (nonatomic, copy) NSString    *addressString;

-(CGFloat)heightOfAddressString;
-(void)setAccessoryButtonView;
-(void)centerAccessoryButtonView;

-(void)directMeHereButtonPressed:(id)sender;
-(void)locationStopChanged:(id)sender;

-(void)showAddress;

@end

@implementation LocationCalloutView2

@synthesize locationLabel = _locationLabel;
@synthesize addressLabel = _addressLabel;
@synthesize hideButton = _hideButton;
@synthesize actionButton = _actionButton;
@synthesize accessoryButton = _accessoryButton;
@synthesize fullViewButton = _fullViewButton;
@synthesize goHereButton = _goHereButton;

@synthesize location = _location;

@synthesize addressString = _addressString;
@synthesize delegate = _delegate;

- (void)dealloc {
    
    self.locationLabel = nil;
    self.addressLabel = nil;
    
    self.hideButton = nil;
    self.actionButton = nil;
    self.fullViewButton = nil;
    self.goHereButton = nil;
    
    self.location.delegate = nil;
    self.location = nil;
    
    self.accessoryButton = nil;
    
    [super dealloc];
}

-(id)initWithLocation:(Location *)location calloutType:(LocationCalloutType)aType
{
    self = [super initWithFrame:CGRectMake(0, 0, kOriginalCalloutWidth,110) withReflectionSlope:0.9 startingX:150 useShadow:NO];
    if(self)
    {
        self.location = location;
        _calloutType = aType;
        
        UILabel *locLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        locLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:17.0];
        locLabel.textAlignment = UITextAlignmentCenter;
        locLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        locLabel.textColor = [UIColor whiteColor];
        locLabel.backgroundColor = [UIColor clearColor];
        self.locationLabel = locLabel;
        [locLabel release];
        
        UILabel *addrLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        addrLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
        addrLabel.textAlignment = UITextAlignmentCenter;
        addrLabel.numberOfLines = 3;
        addrLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        addrLabel.textColor = [UIColor whiteColor];
        addrLabel.backgroundColor = [UIColor clearColor];
        self.addressLabel = addrLabel;
        [addrLabel release];
        
        UIButton *hideButton = [UIButton buttonWithType:UIButtonTypeCustom];
        hideButton.frame = CGRectMake(0, 0, 25, 25);
        hideButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        [hideButton setImage:[UIImage imageNamed:@"hidepin.png"] forState:UIControlStateNormal];
        [hideButton addTarget:self action:@selector(hidePinButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        self.hideButton = hideButton;
        
        UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        actionButton.frame = CGRectMake(0, 0, 25, 25);
        actionButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        [actionButton setImage:[UIImage imageNamed:@"ActionSheet.png"] forState:UIControlStateNormal];
        [actionButton addTarget:self action:@selector(actionSheetButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        self.actionButton = actionButton;
        
        UIButton *goHereButton = [UIButton buttonWithType:UIButtonTypeCustom];
        goHereButton.frame = CGRectMake(0, 0, 65, 65);
        goHereButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
        [goHereButton setImage:[UIImage imageNamed:@"GoHereButton.png"] forState:UIControlStateNormal];
        [goHereButton addTarget:self action:@selector(directMeHereButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        self.goHereButton = goHereButton;
        
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
    //return [self initWithLocation:location calloutType:LocationCalloutTypeNoRoute];
    return [self initWithLocation:location calloutType:LocationCalloutTypeSimple];
    //return [self initWithLocation:location calloutType:LocationCalloutTypePlanning];
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithLocation:nil];
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
    if([self.delegate respondsToSelector:@selector(locationCalloutView:didChangeLocation:)])
    {
        [self.delegate locationCalloutView:self didChangeLocation:self.location];
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
-(void)location:(Location *)loc updatedAddress:(AGSAddressCandidate *)addressCandidate
{
    NSLog(@"Got an address!!");
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
    
    CGRect goHereButtonRect = self.goHereButton.frame;
    if (self.goHereButton.superview == nil) {
        //add subview first here because control doesn't have a height/width yet
        [self addSubview:self.goHereButton];
        
        //then change frame in place
        CGFloat bottomOfHidePin = hideButtonRect.origin.y + hideButtonRect.size.height;
        CGFloat yOrigin = ((contentRect.size.height-bottomOfHidePin) - goHereButtonRect.size.height)/2 + bottomOfHidePin;
        CGFloat xOrigin = 5;
        goHereButtonRect.origin = CGPointMake(xOrigin, yOrigin);
        self.goHereButton.frame = goHereButtonRect;
    } 
    
    //if we now have an address, show above lat/long information
    if ([self.location hasAddress] && self.location.addressString != nil) {
        if (self.addressLabel.superview == nil) {
            
            CGFloat xOriginAddress = goHereButtonRect.origin.x + goHereButtonRect.size.width + 5;
            CGFloat addressWidth = contentRect.size.width - xOriginAddress - 5;
            
            CGRect addressLabelRect = self.addressLabel.frame;
            addressLabelRect.size = CGSizeMake(addressWidth, goHereButtonRect.size.height);
            addressLabelRect.origin = CGPointMake(xOriginAddress, goHereButtonRect.origin.y);
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
    
    self.addressLabel.text = self.location.addressString;
        
    [self setNeedsLayout]; 
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

@end
