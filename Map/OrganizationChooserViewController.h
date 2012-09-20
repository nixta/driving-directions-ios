//
//  OrganizationChooserViewController.h
//  Map
//
//  Created by Scott Sirowy on 10/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

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
    id<OrganizationChooserDelegate> _delegate;
}

@property (nonatomic, retain) IBOutlet UITableView              *tableView;
@property (nonatomic, retain) IBOutlet UIButton                 *finishButton;
@property (nonatomic, assign) NSUInteger                        selectedIndex;

@property (nonatomic, assign) id<OrganizationChooserDelegate>   delegate;

-(id)initWithOrganizations:(NSArray *)organizations;
-(IBAction)finishButtonPressed:(id)sender;

@end

@protocol OrganizationChooserDelegate <NSObject>

-(void)organizationChooser:(OrganizationChooserViewController *)orgVC didChooseOrganization:(Organization *)organization;

@end