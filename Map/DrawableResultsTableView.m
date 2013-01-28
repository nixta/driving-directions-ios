/*
 Copyright © 2013 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

#import "DrawableResultsTableView.h"
#import "DrawableCollection.h"

#define kKeyboardHeight 216

@implementation DrawableResultsTableView


-(id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.dataSource = self;
        self.delegate = self;
    }
    
    return self;
}

//Call to min/max accounting for a keyboard
-(void)minimize
{
    //need to make the table view only as high as the keyboard
    //is, otherwise some elements might not be able to be seen
    if(!_tableViewMinimized)
    {
        CGRect tvRect = self.frame;
        tvRect.size.height -= kKeyboardHeight;
        self.frame = tvRect;
        
        _tableViewMinimized = YES;
    }
}

-(void)maximize
{
    //need to make the table view full size
    if(_tableViewMinimized)
    {
        CGRect tvRect = self.frame;
        tvRect.size.height += kKeyboardHeight;
        self.frame = tvRect;
        
        _tableViewMinimized = NO;
    }
}

#pragma mark -
#pragma mark TableView Data Source
/*Legend Model dictates all of the information to be presented in the tableview */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    @try
    {
        NSLog(@"resultDataSource %@ with count", self.resultsDataSource);
        return [self.resultsDataSource numberOfResultTypes];
    }
    @catch (NSException * e) {
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{    
    return [self.resultsDataSource numberOfResultsInSection:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.resultsDataSource titleOfResultTypeForSection:section];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
    static NSString *DefaultCellIdentifier = @"DefaultCell";
    
    id<TableViewDrawable> currentResult = [self.resultsDataSource resultForRowAtIndexPath:indexPath];
    
    UITableViewCell *cell = nil;
    
    if ([currentResult respondsToSelector:@selector(tableViewCellForTableView:)]) {
        cell = [currentResult tableViewCellForTableView:tableView];  
    }
    /*Doesn't explicitly defining how to draw itself... Do our best to draw it here! */
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:DefaultCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
                                           reuseIdentifier:DefaultCellIdentifier];
        }
        
        cell.textLabel.text = currentResult.name;
        if ([currentResult respondsToSelector:@selector(icon)] && currentResult.icon != nil) 
        {
            cell.imageView.image = currentResult.icon;
        }
        else
        {
            cell.imageView.image = nil;   
        }
        
        if([currentResult respondsToSelector:@selector(detail)] && currentResult.detail != nil)
        {
            cell.detailTextLabel.text = currentResult.detail;
        }
        else
        {
            cell.detailTextLabel.text = nil;
        }
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    [self deselectRowAtIndexPath:indexPath animated:YES];
    
    id<TableViewDrawable> result = [self.resultsDataSource resultForRowAtIndexPath:indexPath];
    
    if ([self.resultsDelegate respondsToSelector:@selector(viewController:didClickOnResult:)]) {
        [self.resultsDelegate viewController:nil didClickOnResult:result];
    }
}

@end
