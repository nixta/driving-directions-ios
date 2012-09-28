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
#import <ArcGIS/ArcGIS.h>
#import "MapStates.h"

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
    id<LocationCalloutDelegate>     __unsafe_unretained _delegate;
    
    NSString                        *_addressString;
    
@private
    BOOL                            _isShowingAccessoryView;
    BOOL                            _showingAddress;
    MapAppState                     _calloutType;

}
@property (nonatomic, strong) UILabel               *locationLabel;
@property (nonatomic, strong) UILabel               *addressLabel;
@property (nonatomic, strong) UIButton              *hideButton;
@property (nonatomic, strong) UIButton              *actionButton;
@property (nonatomic, strong) UIButton              *accessoryButton;
@property (nonatomic, strong) UIButton              *fullViewButton;
@property (nonatomic, strong) UISegmentedControl    *stopSegmentedControl;

@property (nonatomic, strong) Location                      *location;

@property (nonatomic, unsafe_unretained) id<LocationCalloutDelegate>   delegate;

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
