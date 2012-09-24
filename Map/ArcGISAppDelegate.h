//
//  ArcGISAppDelegate.h
//  Map
//
//  Created by Scott Sirowy on 9/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ArcGISMobileConfig;
@class AppSettings;
@class SplashImageVC;

@interface ArcGISAppDelegate : NSObject <UIApplicationDelegate>
{
    UIWindow            *_window;
    UIViewController    *_viewController;
    
    ArcGISMobileConfig  *_config;
    AppSettings         *_appSettings;
    
    NSDictionary        *__unsafe_unretained _launchOptions;
    
    SplashImageVC       *_splashVC;
}

@property (nonatomic, strong) IBOutlet UIWindow             *window;
@property (nonatomic, strong) IBOutlet UIViewController     *viewController;

@property (nonatomic, strong) ArcGISMobileConfig            *config;
@property (nonatomic, strong) AppSettings                   *appSettings;

@property (nonatomic, unsafe_unretained) NSDictionary                  *launchOptions;

@property (nonatomic, strong) SplashImageVC                 *splashVC;

@property (nonatomic, readonly) BOOL                        isIPad;

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

-(void)saveAppState;

-(void)loadSplashScreen;
-(void)unloadSplashScreen;
-(void)launchMethod:(NSDictionary*)appDict;


-(AppSettings *)createAppSettings;
-(AppSettings *)createAppSettingsWithJSON:(NSDictionary *)JSON;

-(void) urisOperation:(NSOperation*)op completedWithResults:(NSDictionary*)results;

@end
