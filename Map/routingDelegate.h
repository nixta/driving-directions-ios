//
//  routingDelegate.h
//  Map
//
//  Created by Al Pascual on 9/27/12.
//
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

@protocol routingDelegate <NSObject>

- (void) appleMapsCalled:(AGSPoint *)pStart withEnd:(AGSPoint*)pEnd;

@end
