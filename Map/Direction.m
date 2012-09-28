//
//  Direction.m
//  Map
//
//  Created by Scott Sirowy on 9/23/11.
/*
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

#import "Direction.h"
#import "UIImage+AppAdditions.h"

@interface Direction () 

@property (nonatomic, strong) UIImage *graphicImage;
@property (nonatomic, strong) NSOperation *graphicOp;
@property (nonatomic, strong) NSOperation *mapOp;
@property (nonatomic, strong) AGSGraphicsLayer *graphicsLayer;
@property (nonatomic, strong) AGSDynamicMapServiceLayer *basemapLayer;

-(void)finishWithSuccess;
-(UIImage *)imageForDirectionManeuver:(AGSNADirectionsManeuver)maneuever;

@end

@implementation Direction

@synthesize geometry        = _geometry;
@synthesize name            = _name;
@synthesize icon            = _icon;
@synthesize mapImage        = _mapImage;
@synthesize delegate        = _delegate;
@synthesize distanceString  = _distanceString;
@synthesize etaString       = _etaString;
@synthesize abbreviatedName = _abbreviatedName;

@synthesize graphicsLayer   = _graphicsLayer;
@synthesize basemapLayer    = _basemapLayer;
@synthesize graphicImage    = _graphicImage;
@synthesize graphicOp       = _graphicOp;
@synthesize mapOp           = _mapOp;

-(void)dealloc
{
    [self.graphicOp cancel];
    [self.mapOp cancel];
    
    
    
}

-(id)initWithSegment:(AGSPolyline *)lineSegment directionText:(NSString *)direction anIcon:(UIImage *)icon;
{
    self = [super init];
    if (self) {
        self.geometry = lineSegment;
        self.name = direction;
        self.icon = icon;
    }
    
    return self;
}

-(id)initWithDirectionGraphic:(AGSDirectionGraphic *)directionGraphic
{
    self = [super init];
    if(self)
    {
        self.geometry = directionGraphic.geometry;
        self.name = directionGraphic.text;
        self.distanceString = [Direction stringForDistance:directionGraphic.length];
        self.etaString = [Direction stringForMinutes:directionGraphic.time];
        self.icon = [self imageForDirectionManeuver:directionGraphic.maneuverType];
    }
    
    return self;
}

- (id)init
{
    return [self initWithSegment:nil directionText:nil anIcon:nil];
}


-(UITableViewCell *)tableViewCellForTableView:(UITableView *)tableView
{
    static NSString *DirectionCellIdentifier = @"DirectionCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DirectionCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DirectionCellIdentifier];
    }
    
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    cell.textLabel.text = self.name;
    cell.imageView.image = self.icon;
    
    return cell;
}

-(void)retrieveMapImageOfSize:(CGSize)size
{
    if (self.mapImage && CGSizeEqualToSize(self.mapImage.size, size)) {
        [self finishWithSuccess];
        return;
    }
    //if retrieval already happening... don't stop it.
    else if(self.mapOp || self.graphicOp)
        return;
    
    //else, haven't started a retrieval yet
    AGSMutableEnvelope *env = [AGSMutableEnvelope envelopeWithXmin:self.geometry.envelope.xmin 
                                                              ymin:self.geometry.envelope.ymin  
                                                              xmax:self.geometry.envelope.xmax  
                                                              ymax:self.geometry.envelope.ymax  
                                                  spatialReference:self.geometry.envelope.spatialReference];
    [env expandByFactor:1.3];
    [env reaspect:size];
    
    AGSExportImageParams *graphicparams = [[AGSExportImageParams alloc] initWithEnvelope:env
                                                                       timeExtent:nil 
                                                                             size:size
                                                                            frame:CGRectMake(0, 0, size.width, size.height) mapWrapAround:YES];
    
    self.graphicOp = [self.graphicsLayer exportMapImage:graphicparams];
    
    
    NSURL *mapUrl = [NSURL URLWithString:@"http://services.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer"]; 
    AGSDynamicMapServiceLayer *dmsl = [[AGSDynamicMapServiceLayer alloc] initWithURL:mapUrl];
    dmsl.exportDelegate = self;
    dmsl.renderNativeResolution = NO;
    
    self.basemapLayer = dmsl;
    
    AGSExportImageParams *mapparams = [[AGSExportImageParams alloc] initWithEnvelope:env 
                                                                       timeExtent:nil 
                                                                             size:size 
                                                                            frame:CGRectMake(0, 0, size.width, size.height) mapWrapAround:YES];
    
    self.mapOp = [self.basemapLayer exportMapImage:mapparams];
}

#pragma mark -
#pragma mark Export Image
- (void)dynamicLayer:(AGSDynamicLayer *)layer exportMapImageOperation:(NSOperation<AGSDynamicLayerDrawingOperation>*)op didFinishWithImage:(UIImage *)image
{
    if (op == self.graphicOp) {
        self.graphicImage = image;
    }
    else if (op == self.mapOp)
    {
        self.mapImage = image;
    }
    
    if (self.graphicImage && self.mapImage) {
        
        self.mapImage = [self.mapImage overlayWithImage:self.graphicImage];
        
        self.graphicOp = nil;
        self.mapOp = nil;
        self.graphicsLayer = nil;
        self.basemapLayer = nil;
        self.graphicImage = nil;
    }    
    
}

-(void)dynamicLayer:(AGSDynamicLayer *)layer exportMapImageOperation:(NSOperation<AGSDynamicLayerDrawingOperation> *)op didFailWithError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(directionDidFailToRetrieveImage:)]) 
    {
        [self.delegate directionDidFailToRetrieveImage:self];
    }
}

#pragma mark -
#pragma mark Class Methods
+(NSString *)stringForDistance:(double)length
{
    NSString *stringToReturn = nil;
    
    //hardwire for miles... needs to be rewritten, and put into a utility class
    if(length < 0.189)  //~1000 ft.
    {
        CGFloat numFeet = round(5280 * length) - ((NSInteger) round(5280 *length))%25;
        if (numFeet > 0) {
            stringToReturn = [NSString stringWithFormat:@"%3.0f ft", numFeet];
        }
        
    }
    else  //mileage
    {
        stringToReturn = [NSString stringWithFormat:@"%.1f mi", round(10.0f * length) / 10.0f];
    }
    
    return stringToReturn;
}

+(NSString *)stringForMinutes:(double)time
{
    NSString *stringToReturn = nil;
    
    //give time in 15 second intervals
    if (time < 1)
    {
        CGFloat numSeconds = round(time*60) - ((NSInteger) round(60 *time))%15;
        if (numSeconds > 0) {
            stringToReturn = [NSString stringWithFormat:@"%.0f sec", numSeconds];
        }
    }
    //just give minutes
    else
    {
        stringToReturn = [NSString stringWithFormat:@"%.0f min", time];
    }
    
    return stringToReturn;
}


#pragma mark -
#pragma mark Private Methods
-(void)finishWithSuccess
{
    if ([self.delegate respondsToSelector:@selector(direction:didRetrieveMapImage:)]) 
    {
        [self.delegate direction:self didRetrieveMapImage:self.mapImage];
    }
}

-(UIImage *)imageForDirectionManeuver:(AGSNADirectionsManeuver)maneuever
{
    UIImage *maneuverImage = nil;
	    
    switch (maneuever) {
        case AGSNADirectionsManeuverDepart:
            maneuverImage = [UIImage imageNamed:@"GreenPin.png"];
            break; 
        case AGSNADirectionsManeuverStop:
            maneuverImage = [UIImage imageNamed:@"RedPin.png"];
            break; 
        case AGSNADirectionsManeuverStraight:
            maneuverImage = [UIImage imageNamed:@"StraightArrow.png"];
            break;
        case AGSNADirectionsManeuverBearLeft:
            maneuverImage = [UIImage imageNamed:@"BearLeft.png"];
            break;
        case AGSNADirectionsManeuverBearRight:
            maneuverImage = [UIImage imageNamed:@"BearRight.png"];
            break;
        case AGSNADirectionsManeuverTurnLeft:
            maneuverImage = [UIImage imageNamed:@"TurnLeft.png"];
            break;
        case AGSNADirectionsManeuverSharpLeft:
            maneuverImage = [UIImage imageNamed:@"TurnSharpLeft.png"];
            break;
        case AGSNADirectionsManeuverTurnRight:
            maneuverImage = [UIImage imageNamed:@"TurnRight.png"];
            break;
        case AGSNADirectionsManeuverSharpRight:
            maneuverImage = [UIImage imageNamed:@"TurnSharpRight.png"];
            break;
        case AGSNADirectionsManeuverRampLeft:
            maneuverImage = [UIImage imageNamed:@"TakeRampLeft.png"];
            break;
        case AGSNADirectionsManeuverForkLeft:
            maneuverImage = [UIImage imageNamed:@"TakeForkLeft.png"];
            break;
        case AGSNADirectionsManeuverRampRight:     
            maneuverImage = [UIImage imageNamed:@"TakeRampRight.png"];
            break;
        case AGSNADirectionsManeuverForkRight:
            maneuverImage = [UIImage imageNamed:@"TakeForkRight.png"];
            break;
        case AGSNADirectionsManeuverHighwayMerge:
            maneuverImage = [UIImage imageNamed:@"MergeOntoHighway.png"];
            break;
        case AGSNADirectionsManeuverHighwayExit:
            maneuverImage = [UIImage imageNamed:@"TakeExit.png"];
            break;
        case AGSNADirectionsManeuverRoundabout:
            maneuverImage = [UIImage imageNamed:@"GetOnRoundabout.png"];
            break;
        case AGSNADirectionsManeuverFerry:
            maneuverImage = [UIImage imageNamed:@"TakeFerry.png"];
            break;
        case AGSNADirectionsManeuverEndOfFerry:
            maneuverImage = [UIImage imageNamed:@"GetOffFerry.png"];
            break;
        case AGSNADirectionsManeuverUTurn:
            maneuverImage = [UIImage imageNamed:@"UTurn.png"];
            break;
        case AGSNADirectionsManeuverForkCenter:
            maneuverImage = [UIImage imageNamed:@"TakeForkCenter.png"];
            break;
        case AGSNADirectionsManeuverHighwayChange:
            maneuverImage = [UIImage imageNamed:@"HighwayChange.png"];
            break;
        default:
            break;
    }
    
    return maneuverImage;
}

#pragma mark -
#pragma mark Lazy Loads
-(NSString *)abbreviatedName
{
    //lame initial attempt at a parser!
    if(_abbreviatedName == nil)
    {
        self.abbreviatedName = self.name;
        
        NSString *departString = @"Depart ";
        NSArray *chunks = [_abbreviatedName componentsSeparatedByString:departString];
        if (chunks.count > 1) {
            //self.abbreviatedName = [chunks objectAtIndex:1];
            self.abbreviatedName = NSLocalizedString(@"Start", nil);
        }
        else
        {
            NSString *arriveString = @"Arrive ";
            NSArray *chunks = [_abbreviatedName componentsSeparatedByString:arriveString];
            if (chunks.count > 1) {
                self.abbreviatedName = NSLocalizedString(@"Destination", nil);
            }
            else
            {
                NSString *toString = @" to ";
                chunks = [_abbreviatedName componentsSeparatedByString:toString];
                if (chunks.count > 1) {
                    self.abbreviatedName = [chunks objectAtIndex:1];
                }
                
                //Check for the "on" string
                NSString *onString = @" on ";
                chunks = [_abbreviatedName componentsSeparatedByString:onString];
                
                if (chunks.count > 1) {
                    self.abbreviatedName = [chunks lastObject];
                    NSString *towardsString = @" toward ";
                    chunks = [_abbreviatedName componentsSeparatedByString:towardsString];
                    if (chunks.count > 1) {
                        self.abbreviatedName = [chunks objectAtIndex:0];
                    }
                } 
                else
                {
                    NSString *towardsString = @" toward ";
                    chunks = [_abbreviatedName componentsSeparatedByString:towardsString];
                    if (chunks.count > 1) {
                        self.abbreviatedName = [chunks objectAtIndex:1];
                    }
                }
            }
        }
    }
    
    return _abbreviatedName;
}

-(AGSGraphicsLayer *)graphicsLayer
{
    if(_graphicsLayer == nil)
    {
        self.graphicsLayer = [AGSGraphicsLayer graphicsLayer];
        self.graphicsLayer.exportDelegate = self;
        self.graphicsLayer.renderNativeResolution = NO;
        
        AGSSimpleLineSymbol *sls = [AGSSimpleLineSymbol simpleLineSymbol];
        sls.width = 7;
        sls.color = [UIColor colorWithRed:(57.0)/255 green:(121.0)/255 blue:(215.0)/255 alpha:1.0];
        
        AGSGraphic *newGraphic = [AGSGraphic graphicWithGeometry:self.geometry symbol:sls attributes:nil infoTemplateDelegate:nil];
        
        //by default add our graphic to it
        [self.graphicsLayer addGraphic:newGraphic];
    }
    
    return _graphicsLayer;
}

@end
