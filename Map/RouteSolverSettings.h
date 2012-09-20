//
//  RouteSolverSettings.h
//  Map
//
//  Created by Scott Sirowy on 11/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ArcGIS+App.h"

/*
 Route solver settings houses all route settings that will be used
 when solving a route. Some of these might be exposed by a UI, others
 might not.
 */

typedef enum {
    RouteSolverTransportationAutomobile = 0,
    RouteSolverTransportationTruck,
    RouteSolverSettingsDeliveryVehicle,
    RouteSolverTransportationEmergencyVehicle
} RouteSolverTransportationType;

@interface RouteSolverSettings : NSObject <AGSCoding>
{
    RouteSolverTransportationType   _transportationType;
    BOOL                            _avoidTollRoads;
    BOOL                            _avoidHighways;
    
    /*... More to come later... */
}

@property (nonatomic, assign) RouteSolverTransportationType transportationType;
@property (nonatomic, assign) BOOL                          avoidTollRoads;
@property (nonatomic, assign) BOOL                          avoidHighways;

-(NSArray *)attributeParameterValues;

@end
