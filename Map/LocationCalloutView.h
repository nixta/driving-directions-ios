//
//  LocationCalloutView.h
//  Map
//
//  Created by Scott Sirowy on 11/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

/*
 Custom callout for showing a location on the map
 */

#import <UIKit/UIKit.h>
#import "BlankSignView.h"
#import "Location.h"
#import "ArcGIS+App.h"

@class Location;
@protocol LocationCalloutDelegate;

@interface LocationCalloutView : BlankSignView <LocationDelegate>
{
    UILabel                         *_locationLabel;
    UILabel                         *_addressLabel;
    UIButton                        *_hideButton;
    UIButton                        *_actionButton;
    UIButton                        *_accessoryButton;
    UIButton                        *_fullViewButton;
    UISegmentedControl              *_stopSegmentedControl;
    
    Location                        *_location;
    id<LocationCalloutDelegate>     _delegate;
    
    NSString                        *_addressString;
    
@private
    BOOL                            _isShowingAccessoryView;
    BOOL                            _showingAddress;
    MapAppState                     _calloutType;

}
@property (nonatomic, retain) UILabel               *locationLabel;
@property (nonatomic, retain) UILabel               *addressLabel;
@property (nonatomic, retain) UIButton              *hideButton;
@property (nonatomic, retain) UIButton              *actionButton;
@property (nonatomic, retain) UIButton              *accessoryButton;
@property (nonatomic, retain) UIButton              *fullViewButton;
@property (nonatomic, retain) UISegmentedControl    *stopSegmentedControl;

@property (nonatomic, retain) Location                      *location;

@property (nonatomic, assign) id<LocationCalloutDelegate>   delegate;

-(id)initWithLocation:(Location *)location;
-(id)initWithLocation:(Location *)location calloutType:(MapAppState)type;

-(IBAction)actionSheetButtonTapped:(id)sender;
-(IBAction)hidePinButtonTapped:(id)sender;

/*Call to add an accessory button to the toolbar */
-(void)showAccessoryView:(BOOL)show;
-(void)showHideButton:(BOOL)show;

@end

@protocol LocationCalloutDelegate <NSObject>

@optional

-(void)locationCalloutView:(LocationCalloutView *)lv actionSheetButtonTappedForLocation:(Location *)location;
-(void)locationCalloutView:(LocationCalloutView *)lv accessoryButtonTappedForLocation:(Location *)location;
-(void)locationCalloutView:(LocationCalloutView *)lv hidePinButtonTappedForLocation:(Location *)location;

-(void)locationCalloutView:(LocationCalloutView *)lv directToLocation:(Location *)location;
-(void)locationCalloutView:(LocationCalloutView *)lv wouldLikeToChangeLocation:(Location *)location toType:(LocationType)type;

@end
