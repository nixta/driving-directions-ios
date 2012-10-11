/*
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

#import "MapShareUtility.h"
#import "Location.h"
#import "Route.h"
#import "StopsList.h"

@interface MapShareUtility () 

@property (nonatomic, assign, readwrite) MapShareInterfaceType  shareType;
@property (nonatomic, strong, readwrite) Route                  *route;
@property (nonatomic, strong, readwrite) Location               *shareLocation;

-(NSMutableArray*)parseCSVString:(NSString*)csvData;

@end

@implementation MapShareUtility

@synthesize shareType       = _shareType;
@synthesize route           = _route;
@synthesize shareLocation   = _shareLocation;
@synthesize callbackString  = _callbackString;


//Url string that app was called with, and spatial reference of actual map
-(id)initWithUrl:(NSURL *)url withSpatialReference:(AGSSpatialReference *)spatialReference locatorURL:(NSURL *)locatorURL
{
    self = [super init];
    if(self)
    {
        NSString *rawStopString = nil;
        
        //Needs to be done in a much better way... i.e error handling, better parsing, etc
        if ([url isFileURL]) {
            NSString *csvData = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
            NSMutableArray *rows = [self parseCSVString:csvData];
            
            rawStopString = @"route/";
            for(int i = 0; i < rows.count; i++)
            {
                NSArray *stop = [rows objectAtIndex:i];
                rawStopString = [rawStopString stringByAppendingString:[stop componentsJoinedByString:@"/"]];
                rawStopString = [rawStopString stringByAppendingString:@"/"];
                NSLog(@"New string: %@", rawStopString);
            }
        }
        else
        {
            rawStopString = url.absoluteString;
        }
        
        NSString *schemeString = [NSString stringWithFormat:@"%@://", @"arcgismap"];
        NSString *urlWithoutHeader = [rawStopString stringByReplacingOccurrencesOfString:schemeString withString:@""];
        urlWithoutHeader = [urlWithoutHeader stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSMutableArray *components = [NSMutableArray arrayWithArray:[urlWithoutHeader componentsSeparatedByString:@"/"]];
        
        NSString *lastComponent = (NSString *)[components lastObject];
        if (lastComponent.length == 0) {
            [components removeObject:lastComponent];
        }
        
        
        NSString *command = [components objectAtIndex:0];
        self.shareType = [command isEqualToString:@"share"] ? MapShareInterfaceShareLocation : MapShareInterfaceShareRoute;
        
        //using a for loop to iterate over all components in url string... If we are looking at a
        //coordinate, we need to look at 4 elements in a row, if a callback, just 2.
        static NSUInteger kParsingCoordinateNumber = 4;
        static NSUInteger kParsingCallbackApp = 2;
        NSUInteger numberToIncrementBy = kParsingCoordinateNumber;
        
        //starting at 1 since the first element will be what we should 
        for(int i = 1; i < components.count-1; i += numberToIncrementBy)
        {
            AGSPoint *coordinatePoint = nil;
            NSString *coordinateName = nil;
            
            NSString *firstArgument = [components objectAtIndex:i];
            
            if ([firstArgument isEqualToString:@"callback"]) {
                numberToIncrementBy = kParsingCallbackApp;
                
                self.callbackString = [components objectAtIndex:i+1];
            }
            //A coordinate
            else
            {
                numberToIncrementBy = kParsingCoordinateNumber;
                
                NSString *coordinateType = firstArgument;
                
                coordinateName = [components objectAtIndex:i+1];
                
                double latitude = [[components objectAtIndex:i+2] doubleValue];
                double longitude = [[components objectAtIndex:i+3] doubleValue];
                
                //build a coordinate point in WGS-84 based on the information given to us
                coordinatePoint = [AGSPoint pointWithX:longitude 
                                                     y:latitude 
                                      spatialReference:[AGSSpatialReference wgs84SpatialReference]];
                
                //project to map spatial reference... in this case web mercator.
                coordinatePoint = (AGSPoint *)[[AGSGeometryEngine defaultGeometryEngine] projectGeometry:coordinatePoint 
                                                                                      toSpatialReference:spatialReference];
                
                Location *newLocation = [[Location alloc] initWithPoint:coordinatePoint 
                                                                   aName:coordinateName 
                                                                  anIcon:[UIImage imageNamed:@"AddressPin.png"] 
                                                              locatorURL:locatorURL];
                
                
                //assuming there is only one location to share... break out of loop
                if(self.shareType == MapShareInterfaceShareLocation)
                {
                    self.shareLocation = newLocation;
                    break;
                }
                
                LocationType locationType = LocationTypeTransitLocation;
                if ([coordinateType isEqualToString:@"startLocation"]) {
                    locationType = LocationTypeStartLocation;
                }
                else if([coordinateType isEqualToString:@"destinationLocation"])
                {
                    locationType = LocationTypeDestinationLocation;
                }
                
                newLocation.locationType = locationType;
                
                if (self.route == nil) {
                    Route *r = [[Route alloc] init];
                    self.route = r;
                }
                
                [self.route addStop:newLocation];
            }
        }
    }
    
    return self;
}

+(NSString *)urlStringForRoute:(Route *)route;
{
    AGSGeometryEngine *ge = [AGSGeometryEngine defaultGeometryEngine];
    
    NSString *body = @"";
    NSString *typeString = @"stopLocation";
    for (int i = 0; i < route.stops.numberOfStops; i++) {
        
        Location *location = [route.stops stopAtIndex:i];
        
        AGSPoint *wgs84Pt = (AGSPoint *)[ge projectGeometry:location.geometry 
                                         toSpatialReference:[AGSSpatialReference wgs84SpatialReference]];
        
        if (location.locationType == LocationTypeStartLocation) {
            typeString = @"startLocation";
        }
        else if(location.locationType == LocationTypeDestinationLocation)
        {
            typeString = @"destinationLocation";
        }
        else
        {
            typeString = @"stopLocation";
        }
        
        NSString *name = (location.name == nil || location.name.length == 0) ? NSLocalizedString(@"Location", nil) : location.name;
        
        body = [body stringByAppendingFormat:@"%@/%@/%f/%f/", typeString, name, wgs84Pt.y, wgs84Pt.x];
    }
    
    body = [body stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [@"arcgismap://route/" stringByAppendingString:body]; 

    return urlString;
}

+(NSString *)urlStringForSharingLocation:(Location *)location
{
    AGSGeometryEngine *ge = [AGSGeometryEngine defaultGeometryEngine];
    
    AGSPoint *wgs84Location = (AGSPoint *)[ge projectGeometry:location.geometry 
                                        toSpatialReference:[AGSSpatialReference wgs84SpatialReference]];
    
    NSString *locationString = [NSString stringWithFormat:@"location/%@/%f/%f", [location searchString], wgs84Location.y, wgs84Location.x];
    
    locationString = [locationString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [@"arcgismap://share/" stringByAppendingString:locationString];
    
    return urlString;
}

#pragma mark -
#pragma mark Private
- (NSMutableArray*) parseCSVString:(NSString*)csvData
{
	NSMutableArray *rows2 = [NSMutableArray array];
	
    // Get newline character set
    NSMutableCharacterSet *newlineCharacterSet = (id)[NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
    [newlineCharacterSet formIntersectionWithCharacterSet:[[NSCharacterSet whitespaceCharacterSet] invertedSet]];
	
    // Characters that are important to the parser
    NSMutableCharacterSet *importantCharactersSet = (id)[NSMutableCharacterSet characterSetWithCharactersInString:@",\""];
    [importantCharactersSet formUnionWithCharacterSet:newlineCharacterSet];
	
    // Create scanner, and scan string
    NSScanner *scanner = [NSScanner scannerWithString:csvData];
    [scanner setCharactersToBeSkipped:nil];
    while ( ![scanner isAtEnd] ) 
	{        
        BOOL insideQuotes = NO;
        BOOL finishedRow = NO;
        NSMutableArray *columns = [NSMutableArray arrayWithCapacity:10];
        NSMutableString *currentColumn = [NSMutableString string];
        while ( !finishedRow ) 
		{
            NSString *tempString;
            if ( [scanner scanUpToCharactersFromSet:importantCharactersSet intoString:&tempString] ) 
			{
                [currentColumn appendString:tempString];
            }
			
            if ( [scanner isAtEnd] ) 
			{
				// trying to allow empty last column - check this
                // if ( ![currentColumn isEqualToString:@""] ) 
                [columns addObject:currentColumn];
				
				finishedRow = YES;
            }
            else if ( [scanner scanCharactersFromSet:newlineCharacterSet intoString:&tempString] ) 
			{
                if ( insideQuotes ) 
				{
                    // Add line break to column text
                    [currentColumn appendString:tempString];
                }
                else 
				{
                    // End of row
					
					// trying to allow empty last column - check this
					// if ( ![currentColumn isEqualToString:@""] ) 
                    [columns addObject:currentColumn];
                    finishedRow = YES;
                }
            }
            else if ( [scanner scanString:@"\"" intoString:NULL] ) 
			{
                if ( insideQuotes && [scanner scanString:@"\"" intoString:NULL] ) 
				{
                    // Replace double quotes with a single quote in the column string.
                    [currentColumn appendString:@"\""]; 
                }
                else 
				{
                    // Start or end of a quoted string.
                    insideQuotes = !insideQuotes;
                }
            }
            else if ( [scanner scanString:@"," intoString:NULL] ) 
			{  
                if ( insideQuotes ) 
				{
                    [currentColumn appendString:@","];
                }
                else 
				{
                    // This is a column separating comma
                    [columns addObject:currentColumn];
                    currentColumn = [NSMutableString string];
                    [scanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:NULL];
                }
            }
        }
        if ( [columns count] > 0 ) [rows2 addObject:columns];
    }
	return rows2;
}


@end
