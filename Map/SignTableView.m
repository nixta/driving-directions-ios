/*
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

#import "SignTableView.h"

@interface SignTableView () 

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation SignTableView


-(void)dealloc
{
    self.tableView.delegate     = nil;
    self.tableView.dataSource   = nil;
    
    
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame dataSource:nil delegate:nil];
}

-(id)initWithFrame:(CGRect)frame dataSource:(id<UITableViewDataSource>)dataSource delegate:(id<UITableViewDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.tableView.delegate = delegate;
        self.tableView.dataSource = dataSource;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

-(void)reloadData
{
    [self.tableView reloadData];
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [self.tableView setEditing:editing animated:animated];
}

-(void)deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

-(void)setDataSource:(id<UITableViewDataSource>)dataSource
{
    self.tableView.dataSource = dataSource;
}

-(void)setDelegate:(id<UITableViewDelegate>)delegate
{
    self.tableView.delegate = delegate;
}

-(void)layoutSubviews
{
    if(self.tableView.superview == nil)
    {
        CGRect tvFrame = [self calculateContentRect:self.bounds];
        self.tableView.frame = tvFrame;

        [self addSubview:self.tableView];
    }
}


@end
