/*
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

#import "SignTableViewCell.h"

@interface SignTableViewCell () 

-(void)resetSubviewsForCurrentLocation:(BOOL)isCurrentLocation;

@end

@implementation SignTableViewCell

@synthesize view                = _view;
@synthesize iconImageView       = _iconImageView;
@synthesize nameLabel           = _nameLabel;
@synthesize distanceLabel       = _distanceLabel;
@synthesize isCurrentLocation   = _isCurrentLocation;


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        _isCurrentLocation = NO;
        
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 295, 44)];
        v.backgroundColor = [UIColor clearColor];
        self.view = v;
                
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectZero];
        iv.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        self.iconImageView = iv;
        
        [self.view addSubview:self.iconImageView];
        
        UILabel *aDistanceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        aDistanceLabel.numberOfLines = 1;
        aDistanceLabel.font = [UIFont fontWithName:@"Verdana-Bold" size:14.0];
        aDistanceLabel.textColor = [UIColor whiteColor];
        aDistanceLabel.backgroundColor = [UIColor clearColor];
        aDistanceLabel.textAlignment = NSTextAlignmentRight;
        aDistanceLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        
        self.distanceLabel = aDistanceLabel;
        
        [self.view addSubview:self.distanceLabel];
        
        UILabel *aNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        aNameLabel.numberOfLines = 0;
        aNameLabel.font = [UIFont fontWithName:@"Verdana-Bold" size:14.0];
        aNameLabel.textColor = [UIColor whiteColor];
        aNameLabel.backgroundColor = [UIColor clearColor];
        aNameLabel.textAlignment = NSTextAlignmentLeft;
        aNameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        self.nameLabel = aNameLabel;
        
        [self.view addSubview:self.nameLabel];
        
        [self resetSubviewsForCurrentLocation:self.isCurrentLocation];
        
        [self.contentView addSubview:self.view];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setIsCurrentLocation:(BOOL)isCurrentLocation
{
    if(_isCurrentLocation == isCurrentLocation)
        return;
    
    _isCurrentLocation = isCurrentLocation;
    [self resetSubviewsForCurrentLocation:self.isCurrentLocation];
}

-(void)resetSubviewsForCurrentLocation:(BOOL)isCurrentLocation
{    
    static CGFloat heightOfIV = 30;
    static CGFloat textHeight = 20;
    static CGFloat widthOfDistanceLabel = 65;
    static CGFloat bufferFromIV = 10;
    
    //The only time this will be a current location is if we are in edit mode... Since
    //current location can't be edited, we need to offset the imageview slightly so it matches
    //well
    CGFloat isCurrentLocationOffset = isCurrentLocation ? 27 : 0;
    CGFloat xOriginIV = 5 + isCurrentLocationOffset;
    
    CGFloat viewHeight = self.view.bounds.size.height;
    CGFloat viewWidth = self.view.bounds.size.width;
    
    CGFloat yOriginIV = (viewHeight - heightOfIV)/2;
    
    CGFloat xOriginDistanceLabel = viewWidth - widthOfDistanceLabel;
    CGFloat yOriginText = (viewHeight - textHeight)/2;
    
    CGFloat xOriginNameLabel = xOriginIV + heightOfIV + bufferFromIV;
    CGFloat widthOfNameLabel = xOriginDistanceLabel - xOriginNameLabel;
    
    self.iconImageView.frame = CGRectMake(xOriginIV, yOriginIV, heightOfIV, heightOfIV);
    
    self.distanceLabel.frame = CGRectMake(xOriginDistanceLabel, yOriginText, widthOfDistanceLabel, textHeight);
    
    self.nameLabel.frame =  CGRectMake(xOriginNameLabel, yOriginText, widthOfNameLabel, textHeight);
}

@end
