//
//  RouteSolverSettings.m
//  Map
//
//  Created by Scott Sirowy on 11/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

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
