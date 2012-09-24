//
//  ArcGISAppDelegate.m
//  Map
//
//  Created by Scott Sirowy on 9/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ArcGISAppDelegate.h"
#import "ArcGISMobileConfig.h"
#import "AppSettings.h"
#import "SplashImageVC.h"

@interface ArcGISAppDelegate () 

-(void)saveAppState:(UIApplication *)application;
-(void)activatePortal:(NSURL *)url;
-(NSString *)portalUrl;

@end

@implementation ArcGISAppDelegate

@synthesize window = _window;
@synthesize viewController=_viewController;
@synthesize config = _config;
@synthesize appSettings = _appSettings;
@synthesize splashVC = _splashVC;
@synthesize launchOptions = _launchOptions;
@synthesize isIPad = _isIpad;

/* AppSettings key - used to save/restore the app settings (will be a JSON NSDictionary)  */
NSString *kAppSettingsKey = @"AppSettings";	// preferences key to obtain our app settings

/*Config File Name */
NSString *kArcGISMobileConfigFilename  = @"arcgismobile.txt";

/*Default Portal... i.e ArcGIS */
static NSString *kDefaultPortalUrl = @"http://www.arcgis.com";

#pragma mark -
#pragma mark Lifetime


#pragma mark -
#pragma mark UIApplicationDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self loadSplashScreen];
    	
	NSDictionary *appDict = [NSDictionary dictionaryWithObjectsAndKeys:
							 application, @"app",
							 launchOptions, @"options",
							 nil];						
	
	[self performSelector:@selector(launchMethod:) withObject:appDict afterDelay:0.0];
    
    /*
	NSURL *openWithURL = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
    if (openWithURL)
    {   
        //verify we have the correct scheme
        if (![[openWithURL scheme] isEqualToString:kArcGISURLScheme] &&
            ![[openWithURL scheme] isEqualToString:kArcGISPortalURLScheme])
		{
			return NO;
		}
    }  */
    
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait ||
            interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void) applicationWillTerminate:(UIApplication *)application{
    [self saveAppState:application];
}

- (void)applicationDidEnterBackground:(UIApplication *)application{
    [self saveAppState:application];
}

#pragma mark -
#pragma mark Splash Screen Stuff
-(void)loadSplashScreen
{
    // add splash in case we take a little while to load...
	// this check is here in case we have to re-attempt to launch the app
	if (self.splashVC.view.superview == nil) {
		[self.window addSubview:self.splashVC.view];
		[self.window setAutoresizesSubviews:YES];
		self.window.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self.window makeKeyAndVisible];		
	}
}

-(void)unloadSplashScreen
{
    
}

#pragma mark -
#pragma mark Application Shutdown stuff

- (void)saveAppState
{
    [self saveAppState:[UIApplication sharedApplication]];
}

- (void)saveAppState:(UIApplication *)application
{    
    // save the current App Settings
    NSDictionary *appSettingsJSON = [self.appSettings encodeToJSON];
    NSString *sJSONRepresentation = [appSettingsJSON AGSJSONRepresentation];
	[[NSUserDefaults standardUserDefaults] setObject:sJSONRepresentation forKey:kAppSettingsKey];
        
	[[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark -
#pragma mark Launching Methods
- (void)launchMethod:(NSDictionary*)appDict {
    
	self.launchOptions = (NSDictionary*)[appDict objectForKey:@"options"];
    
	//
	// set additional user agent info
	NSString *versionNumber = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
	NSString *buildNumber = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	NSString *userAgentInfo = [NSString stringWithFormat:@"ArcGISApp/%@.%@",versionNumber,buildNumber];
	[AGSRequest setAdditionalUserAgentInfo:userAgentInfo];
    
    //this handles parsing the incoming url, if any, for custom portal information.
    //it also initiates loading the portal configuration file.
    NSURL *openWithURL = [self.launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
    [self activatePortal:openWithURL];
    
	// load the stored preference of the user's last app settings from a previous launch
	NSString *sAppSettings = [[NSUserDefaults standardUserDefaults] objectForKey:kAppSettingsKey];
	if (sAppSettings == nil)
	{
		// user has not launched this app, create default app settings
		self.appSettings = [self createAppSettings];
		
        // register our preference selection data to be archived
        sAppSettings = [[self.appSettings encodeToJSON] AGSJSONRepresentation];
        NSDictionary *appSettingsDictionary = [NSDictionary dictionaryWithObject:sAppSettings forKey:kAppSettingsKey];
        [[NSUserDefaults standardUserDefaults] registerDefaults:appSettingsDictionary];
        [[NSUserDefaults standardUserDefaults] synchronize];
	}
	else
	{
        self.appSettings = [self createAppSettingsWithJSON:[sAppSettings AGSJSONValue]];
	}
	 
	// reshow status bar (initially hidden by plist setting)
	[[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.window addSubview:self.viewController.view];
    [self.window makeKeyAndVisible];
    
    //don't need splash image view anymore
	[self.splashVC.view removeFromSuperview];
	self.splashVC = nil;
}

- (void)activatePortal:(NSURL *)url {
    
    //the portal to use...
    NSString *currentPortalUrl = nil;
    
    /*  All commented out for now.  Can re-add later 
     
     
     
    //set the mapUrl to open.  This will get checked in the connection handler
    //for the portal config, which will then open it.  If this is set to nil in the
    //block below (when we have a valid arcgis portal scheme), then the handler
    //will know to open the default map for the portal...
    self.mapUrl = url;
    
    //the portal to use...
    NSString *currentPortalUrl = nil;
    
    //openWithURL is the url that was used to launch our app
    //if it's nil, then a url wasn't used and we launched normally
    if (url &&
        [[url scheme] isEqualToString:kArcGISPortalURLScheme])
    {
        //we're launching with a custom portal scheme...
        NSString *schemeString = [NSString stringWithFormat:@"%@://", kArcGISPortalURLScheme];
        
        //replace 'agsportal://' with 'http://' or 'https://' to get the real portal url
        NSString* sUrl = [url absoluteString];
        
        NSString *fragment = [url fragment];
        NSString *prefix = @"http://";
        if (fragment && ([fragment rangeOfString:kSecureFragment].location != NSNotFound))
        {
            //need secure url
            prefix = @"https://";
        }
        
        currentPortalUrl = [sUrl stringByReplacingOccurrencesOfString:schemeString withString:prefix];
        
        //set custom portal url preference:
        [[NSUserDefaults standardUserDefaults] setObject:currentPortalUrl forKey:kCustomPortalURL_preference];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:kPortalSelection_preference];
        
        //set the newMapUrl to nil, so we open up with the default map
        self.mapUrl = nil;
        
        //make sure defaults are up to date
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //    NSLog(@"%@", @"applicationDidBecomeActive");
        
        //get saved portal (this was saved during 'activatePortal', so it is the one we
        //last tried to open
        NSString *savedPortal = [[NSUserDefaults standardUserDefaults] objectForKey:kSavedPortalURL];
        if (!savedPortal || (savedPortal == (id)[NSNull null]))
        {
            //don't have a saved portal yet, set it so we don't erroneously display error to user
            [[NSUserDefaults standardUserDefaults] setObject:currentPortalUrl forKey:kSavedPortalURL];
            savedPortal = currentPortalUrl;
        }
        
        if (![savedPortal isEqualToString:currentPortalUrl])
        {
            //the message is in two parts so we can use the first part in the 
            //'willEnterForeground' method.
            
            NSString *sMessage = [NSString stringWithFormat:NSLocalizedString(@"PortalChangedMessage", nil),
                                  currentPortalUrl];
            
            
            NSString *sConfirmMessage = [NSString stringWithFormat:NSLocalizedString(@"PortalChangeConfirmMessage", nil),
                                         savedPortal];
            
            sMessage = [sMessage stringByAppendingFormat:@"  %@", sConfirmMessage];            
            
            //current portal is not the last one we tried to open, so inform the user...
            self.portalChangeConfirmAlertView = [[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"ArcGIS Portal Change", nil)
                                                                           message:sMessage
                                                                          delegate:nil
                                                                 cancelButtonTitle:NSLocalizedString(@"Original", nil)
                                                                 otherButtonTitles:NSLocalizedString(@"New Portal", nil), nil] autorelease];
            self.portalChangeConfirmAlertView.delegate = self;
            [self.portalChangeConfirmAlertView show];
            
            //need to let the use decide what to do, so the continuation of this
            //will be in the UIAlertView delegate method
            return;
        }
    }
     
     */
    
    //
    // Application Settings - (iOS Settings Application preferences)
    //    
    if (!currentPortalUrl)
    {
        //if we have't gotten the portal from any launch option, get it here...
        currentPortalUrl = [self portalUrl];        
    }
	
	//
	// kick off operation to load portal configs
    //
    NSString *configUrl = [NSString stringWithFormat:@"%@/%@", currentPortalUrl, kArcGISMobileConfigFilename];
	AGSJSONRequestOperation *urisRequestOp = [[AGSJSONRequestOperation alloc]initWithURL:[NSURL URLWithString:configUrl]];
	urisRequestOp.target = self;
	urisRequestOp.action = @selector(urisOperation:completedWithResults:);
	urisRequestOp.errorAction = @selector(urisOperation:didFailWithError:);
	[[AGSRequestOperation sharedOperationQueue] addOperation:urisRequestOp];
}


-(NSString *)portalUrl
{
    /*
    NSString *currentPortalUrl = nil;
    if ([self portalSelection] > 0)
    {
        //not using default portal, so grab custom portal url from user defaults
        currentPortalUrl = [[NSUserDefaults standardUserDefaults] objectForKey:kCustomPortalURL_preference];
        if (!currentPortalUrl)
        {
            //we're supposed to be using a custom portal, but one isn't defined
            //so reset the portal selection to the default (0)
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:kPortalSelection_preference];
        }
    }
    
    if (!currentPortalUrl)
    {
        //don't have a custom portal, so use the default.
        currentPortalUrl = kDefaultPortalUrl;
    }
    
    return currentPortalUrl;  */
    
    return kDefaultPortalUrl;
}


#pragma mark -
#pragma mark urisOperation

-(void) urisOperation:(NSOperation*)op completedWithResults:(NSDictionary*)results{
    
    self.config = [[ArcGISMobileConfig alloc] initWithJSON:results];

    /*
    //get portal name and set if necessary...
	NSString *customPortalName = [[NSUserDefaults standardUserDefaults] objectForKey:kCustomPortalName_preference];
	NSNumber *portalSelection = [[NSUserDefaults standardUserDefaults] objectForKey:kPortalSelection_preference];
    if ([portalSelection intValue] > 0 &&
        (!customPortalName ||
         ![customPortalName isEqual:self.config.portalName]))
    {
        //we're not pointing to ArcGIS.com AND
        //there is no custom portal name in preferences OR there is one but it's not the just loaded one.
        
        //so, set it in the preferences
        [[NSUserDefaults standardUserDefaults] setObject:self.config.portalName forKey:kCustomPortalName_preference];
    }
    
    if (self.openDefaultMap)
    {
        //open default map for portal...
        NSDictionary *json = [self.config.defaultMap JSONValue];
        [self openMobileWebMapWithJSON:json withExtent:self.config.defaultMapExtent];
    }
    else {
        //we have a valid url, so continue with opening it
        [self openMapWithURL:self.mapUrl];
    }
    
    self.openDefaultMap = NO;
    
	//variable is for handling shared map url's when opening maps
	//from a closed app, and running from a previously run instance of
	//the map
	_appLaunchedSuccessfully = YES;    
     
     
     */
}

-(BOOL)isIPad
{
    //check and see if we're on an iPad
    BOOL _isIPad = NO;
		
    UIDevice *device = [UIDevice currentDevice];
    if ([device respondsToSelector:@selector(userInterfaceIdiom)])
    {
        UIUserInterfaceIdiom uiIdiom = device.userInterfaceIdiom;
        _isIPad = (uiIdiom == UIUserInterfaceIdiomPad);
    }
    
    return _isIPad;
}


#pragma mark -
#pragma mark App Settings Creation.  
/*
 These should be partially overridden if you have any custom app settings 
 */

-(AppSettings *)createAppSettings
{
    //+1 ref count since using the word 'create' in method name.  
    //Caller should handle memory
    return [[AppSettings alloc] init];
}

-(AppSettings *)createAppSettingsWithJSON:(NSDictionary *)JSON
{
    //+1 ref count since using the word 'create' in method name.  
    //Caller should handle memory
    return [[AppSettings alloc] initWithJSON:JSON];
}
 


#pragma mark -
#pragma mark Lazy Loads
-(SplashImageVC *)splashVC
{
    if (_splashVC == nil) {
		SplashImageVC *sivc = [[SplashImageVC alloc] init];
		self.splashVC = sivc;
	}
    
    return _splashVC;
}


@end
