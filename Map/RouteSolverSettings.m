/*

 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

#import "RouteSolverSettings.h"

@implementation RouteSolverSettings

@synthesize transportationType = _transportationType;
@synthesize avoidTollRoads = _avoidTollRoads;
@synthesize avoidHighways  = _avoidHighways;

- (id)initWithJSON:(NSDictionary *)json
{
    self = [self init];
    if(self)
    {
        [self decodeWithJSON:json];
    }
    return self;
}

- (void)decodeWithJSON:(NSDictionary *)json
{
    NSLog(@"Decoding Route Solver JSON");
}

- (NSDictionary *)encodeToJSON
{
    NSLog(@"Encoding Route Solver JSON");
    return nil;
}

-(NSArray *)attributeParameterValues
{
    NSString *routeTypeString = nil;
    switch (_transportationType) {
        case RouteSolverTransportationAutomobile:
            routeTypeString = @"Driving an Automobile";
            break;
        case RouteSolverTransportationTruck:
            routeTypeString = @"Driving a Truck";
            break;
        case RouteSolverSettingsDeliveryVehicle:
            routeTypeString = @"Driving a Delivery Vehicle";
            break;
        case RouteSolverTransportationEmergencyVehicle:
            routeTypeString = @"Driving an Emergency Vehicle";
            break;
        default:
            break;
    }
    
    NSDictionary *routeTypeDictionary = [NSDictionary dictionaryWithObjectsAndKeys:routeTypeString, @"attributeName", @"Restriction Usage", @"parameterName", nil];
    
    NSArray *attributes = [NSArray arrayWithObject:routeTypeDictionary];
    return attributes;
}

@end
