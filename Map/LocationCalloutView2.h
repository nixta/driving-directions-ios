//
//  LocationCalloutView.h
//  Map
//
//  Created by Scott Sirowy on 11/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlankSignView.h"
#import "Location.h"
#import "LocationCalloutView.h"

@class Location;
@protocol LocationCalloutDelegate;

@interface LocationCalloutView2 : BlankSignView <LocationDelegate>
{
    UILabel                         *_locationLabel;
    UILabel                         *_addressLabel;
    UIButton                        *_hideButton;
    UIButton                        *_actionButton;
    UIButton                        *_accessoryButton;
    UIButton                        *_fullViewButton;
    UIButton                        *_goHereButton;
    
    Location                        *_location;
    id<LocationCalloutDelegate>     _delegate;
    
    NSString                        *_addressString;
    
@private
    BOOL                            _isShowingAccessoryView;
    LocationCalloutType             _calloutType;

}
@property (nonatomic, retain) UILabel               *locationLabel;
@property (nonatomic, retain) UILabel               *addressLabel;
@property (nonatomic, retain) UIButton              *hideButton;
@property (nonatomic, retain) UIButton              *actionButton;
@property (nonatomic, retain) UIButton              *accessoryButton;
@property (nonatomic, retain) UIButton              *fullViewButton;
@property (nonatomic, retain) UIButton              *goHereButton;

@property (nonatomic, retain) Location                      *location;

@property (nonatomic, assign) id<LocationCalloutDelegate>   delegate;

-(id)initWithLocation:(Location *)location;
-(id)initWithLocation:(Location *)location calloutType:(LocationCalloutType)type;

-(IBAction)actionSheetButtonTapped:(id)sender;
-(IBAction)hidePinButtonTapped:(id)sender;

/*Call to add an accessory button to the toolbar */
-(void)showAccessoryView:(BOOL)show;

@end