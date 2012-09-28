//
//  OrganizationChooserViewController.h
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

#import <UIKit/UIKit.h>

@protocol OrganizationChooserDelegate;
@class Organization;

/*
 Throwaway view controller for connecting to a few different types of 'ogranizations'.
 For demo purposes only
 */

@interface OrganizationChooserViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    UITableView                     *_tableView;
    UIButton                        *_finishButton;
    
    
    NSArray                         *_organizations;
    NSUInteger                      _selectedIndex;
    id<OrganizationChooserDelegate> __unsafe_unretained _delegate;
}

@property (nonatomic, strong) IBOutlet UITableView              *tableView;
@property (nonatomic, strong) IBOutlet UIButton                 *finishButton;
@property (nonatomic, assign) NSUInteger                        selectedIndex;

@property (nonatomic, unsafe_unretained) id<OrganizationChooserDelegate>   delegate;

@property (nonatomic,strong) NSTimer *timer;

-(id)initWithOrganizations:(NSArray *)organizations;
-(IBAction)finishButtonPressed:(id)sender;

@end

@protocol OrganizationChooserDelegate <NSObject>

-(void)organizationChooser:(OrganizationChooserViewController *)orgVC didChooseOrganization:(Organization *)organization;

@end