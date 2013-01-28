/*
 Copyright © 2013 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

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
