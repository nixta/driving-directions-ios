//
//  SignTableView.m
//  StreetSignTest
//
//  Created by Scott Sirowy on 11/17/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SignTableView.h"

@interface SignTableView () 

@property (nonatomic, retain) UITableView *tableView;

@end

@implementation SignTableView

@synthesize tableView = _tableView;

-(void)dealloc
{
    self.tableView.delegate     = nil;
    self.tableView.dataSource   = nil;
    self.tableView              = nil;
    
    
    [super dealloc];
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
        self.tableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
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
