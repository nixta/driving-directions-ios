//
//  ArcGISOnlineConnection.h
//  ArcGISMobile
//
//  Created by Mark Dostal on 2/22/10.
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

@class User;
@class TokenResponse;
@class ArcGISAppDelegate;

@interface ArcGISOnlineConnection : NSObject <AGSCoding> {
    NSURLCredential     *_credential;
    NSString            *_token;
    
    ArcGISAppDelegate   *__unsafe_unretained _app;
}

@property (nonatomic, strong) NSURLCredential   *credential;
@property (nonatomic, strong) NSString          *token;
@property (nonatomic, unsafe_unretained) ArcGISAppDelegate *app;



/// <summary>
/// Connects to the ArcGIS Online server and obtains a token for subsequent
/// queries/operations.
/// </summary>
/// <param name="credentials"></param>
/// <returns></returns>
- (BOOL)signInWithCredential:(NSURLCredential*)credential error:(NSError **)error;

/// <summary>
/// Disconnects from the ArcGIS Online server.
/// </summary>
- (void)signOut;

/// <summary>
/// Issues a 'generateToken' request to the ArcGIS Online server.
/// </summary>
/// <param name="credentials">ArcGIS Online credentials.</param>
/// <returns>token response.</returns>
+ (TokenResponse *)generateToken:(NSURLCredential*)credential error:(NSError **)error;

//
// This method will create, start, and return a connection with the given
// url string.  The string will have any ' ' or '"' converted
// correctly.  If the user is signed into AGOL, it will also contain
// the token and referer information in the request.
//
+ (NSURLConnection *)generateURLConnection:(NSString *)url withDelegate:(id)delegate;

//
// Same as above, but with an alternate host (used for ArcGIS Servers).
//
+ (NSURLConnection *)generateURLConnection:(NSString *)url withDelegate:(id)delegate withHost:(NSString *)host;

//
// This method gets the json dictionary from a partial url.  It will
// insert the current AGOL connection and any token information,
// if necessary (meaning if the user is signed in).
//
// This is a SYNCHRONOUS call.
//
+(NSDictionary *)getDataFromUrl:(NSString *)sUrl;

//
// Returns the currently selected AGOL location.
// The current location is retrieved from the appSettings
// property in the ArcGISMobileAppDelegate
//
+ (NSString *)portalSharingLocation;

//
// sanitizes url string and request a url request
//
- (NSURLRequest *)requestForUrlString:(NSString *)urlString withHost:(NSString *)host;


#ifdef TABLET_CODE

//TODO:  find out where this is in the code.  Maybe replace that.

/// <summary>
/// Returns a list of windows mobile packages in a given group that are 
/// the currently signed in user has access to.
/// </summary>
/// <param name="groupId"></param>
/// <returns></returns>
public IList<ContentItem> GetMobilePackages(string groupId)

/// <summary>
/// Downlods the data component of an item from the ArcGIS Online server
/// and saves it to a given directory. 
/// </summary>
/// <param name="item">The item to download.</param>
/// <param name="outputDirectory">The directory to save the item to.</param>
/// <param name="itemPath">Full path of the downloaded file.</param>
/// <returns>True if the item was successfully downloaded; otherwise, false.</returns>
public bool GetItemData(ContentItem item, string outputDirectory, out string itemPath)


/// <summary>
/// Gets the location of the ArcGIS Online server. E.g., 
/// www.arcgisonline.com.
/// </summary>
internal static string ArcGisOnlineLocation

/// <summary>
/// Issues a 'user' request to the ArcGIS Online server to retrieve 
/// information about a given user.
/// </summary>
/// <param name="username">The username to request the information for.</param>
/// <param name="token">Security token.</param>
/// <returns>User response.</returns>
internal static User GetUserInfo(string username, string token)

/// <summary>
/// Issues a query to the ArcGIS Online server for all windows mobile 
/// packages in a particular group.
/// </summary>
/// <param name="groupId">The user group.</param>
/// <param name="start">The number of the first entry to include in the result set.</param>
/// <param name="maxCount">The maximum number of results to include in the result set.</param>
/// <param name="token">Security token.</param>
/// <returns>Search response.</returns>
internal static SearchResponse GetWindowsMobilePackages(string groupId, int start, int maxCount, string token)

/// <summary>
/// Downlods the data component of an item from the ArcGIS Online server
/// and saves it to a file.
/// </summary>
/// <param name="itemId">The item to download.</param>
/// <param name="token">Security token.</param>
/// <param name="outputFilePath">Path of the file to save the item to.</param>
internal static void GetItemData(string itemId, string token, string outputFilePath)
#endif //TABLET_CODE







@end