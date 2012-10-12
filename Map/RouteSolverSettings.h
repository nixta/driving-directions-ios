/*

 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

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
