//
//  ArcGISOnlineConnection.m
//  ArcGISMobile
//
//  Created by Mark Dostal on 2/22/10.
//  Copyright 2010 ESRI. All rights reserved.
//

#import "ArcGISOnlineConnection.h"
#import "ArcGISOnlineServices.h"
#import "ArcGISAppDelegate.h"
#import "ArcGISMobileConfig.h"
#import "AppSettings.h"
#import "NSDictionary+Additions.h"
#import "KeychainWrapper.h"
#import "OnlineApplication.h"
#import "AppSettings.h"

@interface ArcGISOnlineConnection ()

//
// This method creates an NSURLRequest object with the given url
// If this connection is logged in, it will also use the token
// and referer using an NSMutableURLRequest
//
- (NSURLRequest *)requestForUrlString:(NSString *)url withHost:(NSString *)host;

@end


@implementation ArcGISOnlineConnection

static NSString* _referer = @"www.esri.com/arcgismobile";

@synthesize credential = _credential;
@synthesize token = _token;
@synthesize app = _app;

-(id)init
{
	if (self = [super init])
	{
        self.token = @"";
        self.credential = [[[NSURLCredential alloc] initWithUser:@"" password:@"" persistence:NSURLCredentialPersistenceNone] autorelease];
	}
	return self;
}

-(ArcGISAppDelegate *)app
{
    if(_app == nil){
        self.app = [[UIApplication sharedApplication] delegate];
    }
    
    return _app;
}

#pragma mark -
#pragma mark AGSCoding

- (void)decodeWithJSON:(NSDictionary *)json {
    
    //get the password for 'user' from the keychain...
    NSString *password = @"";
    NSString *user = @"";
    
    KeychainWrapper *kcw = nil;
    if ([self.app conformsToProtocol:@protocol(OnlineApplication)]) {
        id<OnlineApplication> onlineApp = (id<OnlineApplication>)self.app;
        kcw = onlineApp.keychainWrapper;
    }
    
    if ([kcw isLoggedIn])
    {
        password = [kcw getPassword];
        user = [kcw getUser];

        //get saved token...
        self.token = [AGSJSONUtility getStringFromDictionary:json withKey:@"token"];
    }

    self.credential = [NSURLCredential credentialWithUser:user password:password persistence:NSURLCredentialPersistenceNone];
}

- (id)initWithJSON:(NSDictionary *)json {
    if (self = [super init]) {
        [self decodeWithJSON:json];
    }
    return self;
}

- (NSDictionary *)encodeToJSON;
{
	NSMutableDictionary *json = [NSMutableDictionary dictionaryWithCapacity:2];
	
	[NSDictionary safeSetObjectInDictionary:json object:self.token withKey:@"token"];
//	[NSDictionary safeSetObjectInDictionary:json object:self.credential.user withKey:@"user"];
    
    return json;
}

#pragma mark -
#pragma mark ArcGISOnlineConnection

- (BOOL)isSignedIn
{
    KeychainWrapper *kcw = nil;
    if ([self.app conformsToProtocol:@protocol(OnlineApplication)]) {
        id<OnlineApplication> onlineApp = (id<OnlineApplication>)self.app;
        kcw = onlineApp.keychainWrapper;
    }
    return ([kcw isLoggedIn] && self.token != nil && self.token.length > 0);
}

- (BOOL)signInWithCredential:(NSURLCredential*)credential error:(NSError **)error
{
    if ([self isSignedIn] != NO)
    {
        [self signOut];
    }
    
    TokenResponse *tokenResponse = nil;
    
    // First obtain a token using the credentials.
//    try
//    {
    
    //
    //this is the method which actually logs in.  This would need to be synchronous??  (ok for now)
    //
    tokenResponse = [ArcGISOnlineConnection generateToken:credential error:error];
    if (tokenResponse == nil || tokenResponse.token == nil)
        return NO;
//    }
//    catch (Exception ex)
//    {
//        System.Diagnostics.Debug.WriteLine(ex.Message);
//        return false;
//    }
    
    // Get information about the user.
//    User* user = nil;
////    try
////    {
//    user = [ArcGisOnlineConnection GetUserInfo:credentials.UserName token:tokenResponse.Token];
//    if (user == nil)
//        return NO;
//    }
//    catch (Exception ex)
//    {
//        System.Diagnostics.Debug.WriteLine(ex.Message);
//        return false;
//    }
    
    self.credential = credential;
    self.token = tokenResponse.token;
    
    //store successful username/password to the keychain...
    KeychainWrapper *kcw = nil;
    if ([self.app conformsToProtocol:@protocol(OnlineApplication)]) {
        id<OnlineApplication> onlineApp = (id<OnlineApplication>)self.app;
        kcw = onlineApp.keychainWrapper;
    }
    [kcw setPassword:credential.password forUser:credential.user];
    
    //save app state so we save the token.
    //this will prevent issues at startup if the app crashes
    //and doesn't save the token
    [_app saveAppState];
    
//    self.user = user;
    
    //[user release];

    return YES;
}

- (void)signOut
{
    self.token = nil;
    self.credential = nil;
    
    KeychainWrapper *kcw = nil;
    if ([self.app conformsToProtocol:@protocol(OnlineApplication)]) {
        id<OnlineApplication> onlineApp = (id<OnlineApplication>)self.app;
        kcw = onlineApp.keychainWrapper;
    }
    
    if ([kcw isLoggedIn])
    {
        [kcw resetKeychainItem];        
    }
}

/// <summary>
/// Issues a 'generateToken' request to the ArcGIS Online server.
/// </summary>
/// <param name="credentials">ArcGIS Online credentials.</param>
/// <returns>Generate token response.</returns>
+ (TokenResponse*)generateToken:(NSURLCredential*)credential error:(NSError **)error
{
    NSString* _curLocation = [ArcGISOnlineConnection portalSharingLocation];

    //the main url
    NSString* urlString = [NSString stringWithFormat:@"%@/generateToken", _curLocation];
    
    //make sure we're using https
    if ([urlString rangeOfString:@"https"].location == NSNotFound)
    {
        urlString = [urlString stringByReplacingOccurrencesOfString:@"http" withString:@"https"];
    }
    
    //the query string that goes in the request http body (for security reasons and the POST operation)
    ArcGISAppDelegate *a = [[UIApplication sharedApplication] delegate];
    NSUInteger tokenExpiration = a.config.tokenExpiration;

    //
    // make sure there is a valid username/credential
    if (![credential user] || ![credential hasPassword]) {
        return nil;
    }
    
    //
    // encode username and password in case they contain special characters
    NSString *escapedUsername = [AGSCredential ags_sanitizeString:credential.user];
    NSString *escapedPW = [AGSCredential ags_sanitizeString:credential.password];
    
    NSString* queryString = [NSString stringWithFormat:@"f=json&client=referer&referer=%@&username=%@&password=%@&expiration=%u",
                              _referer,
                              escapedUsername,
                              escapedPW,
                              tokenExpiration];
    
    NSURL* url = [NSURL URLWithString:urlString];
    
    //this is a mutable request so we can set the http method and body
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    NSData *httpBodyData = [queryString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:httpBodyData];    
    
    NSURLResponse* response;
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:error];
    
    NSString* strData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    //NSLog(@"%@", strData);

    NSDictionary *json = [strData AGSJSONValue];
    TokenResponse* tokenResponse = [[TokenResponse alloc] init];
    [tokenResponse decodeWithJSON:json];
    
    [strData release];
    return [tokenResponse autorelease];
}

+ (NSURLConnection *)generateURLConnection:(NSString *)url withDelegate:(id)delegate
{
    return [self generateURLConnection:url withDelegate:delegate withHost:nil];
}

+ (NSURLConnection *)generateURLConnection:(NSString *)urlString withDelegate:(id)delegate withHost:(NSString *)host
{
    ArcGISAppDelegate *_app = (ArcGISAppDelegate *)[UIApplication sharedApplication].delegate;
    ArcGISOnlineConnection *connection = _app.appSettings.arcGISOnlineConnection;
	
    //NSLog(@"connection url: %@", urlString);
    
	//create the url request, complete with token and referer, if signed in
	NSURLRequest *contentReq = [connection requestForUrlString:urlString withHost:host];
    NSAssert(contentReq != nil, @"NSURLRequest is nil");
    
	NSURLConnection *urlConnection = [NSURLConnection connectionWithRequest:contentReq delegate:delegate];
    
    //since we did not 'alloc-init' the NSURLconnection, it should already be autoreleased
    return urlConnection;
}


+(NSDictionary *)getDataFromUrl:(NSString *)urlString
{
    //append token, if necessary
    ArcGISAppDelegate *_app = (ArcGISAppDelegate *)[UIApplication sharedApplication].delegate;
    ArcGISOnlineConnection *connection = _app.appSettings.arcGISOnlineConnection;
    
    NSURLRequest *request = [connection requestForUrlString:urlString withHost:nil];
    
	NSError *err = nil;
    NSURLResponse *response = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    //     NSLog(@"\r\n\r\n\r\n");
    //     NSLog(@"-------------");
    //    NSLog(@"---url: %@", urlString);
    //     NSLog(@"---response: %@",responseString);
	
    NSDictionary *json = [responseString AGSJSONValue];
    [responseString release];
    
    return json;
}

- (NSURLRequest *)requestForUrlString:(NSString *)urlString withHost:(NSString *)host
{
    if (urlString == nil || [urlString length] <= 0)
        return nil;
    
    //use host... if host is nil, use portalSharingLocation...
    NSString *hostLocation = (host != nil) ? host : [ArcGISOnlineConnection portalSharingLocation];
    
    NSURLRequest *request = nil;
    
    //
    // sanitize url string
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	urlString = [urlString stringByReplacingOccurrencesOfString:@"'" withString:@"%22"];
    
    //use token stuff if we're signed in and we're NOT using an alternate host
    if ([self isSignedIn] && !host)
    {
        //check to see if we have an '?' in the url...
        //if we do, then to separator needs to be a "&";
        //if not, then the separator needs to be a "?"
        NSString *separator = @"&";
        NSRange range = [urlString rangeOfString:@"?"];
        if (range.location == NSNotFound)
            separator = @"?";

        NSString *secureURL = [NSString stringWithFormat:@"%@/%@%@token=%@",
                               hostLocation,
                               urlString,
                               separator,
                               self.token];
        
        //NSLog(@"SecureURL = %@", secureURL);
        
        NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:[[NSURL URLWithString:secureURL] standardizedURL]];
        [req setValue:_referer forHTTPHeaderField:@"Referer"];
        request = req;        
    }
    else {
        urlString = [NSString stringWithFormat:@"%@/%@",
                     hostLocation,
                     urlString];
        
        NSURLRequest *req = [[NSURLRequest alloc] initWithURL: [[NSURL URLWithString:urlString] standardizedURL]];
        request = req;        
    }
    
    return [request autorelease];
}

+ (NSString *)portalSharingLocation
{
    ArcGISAppDelegate *a = (ArcGISAppDelegate *)[UIApplication sharedApplication].delegate;
    return a.config.sharing;
    //return @"http://dev.arcgis.com/sharing";
}

- (void)dealloc
{
    self.credential = nil;
    self.token = nil;
    
    [super dealloc];
}
@end


#ifdef TABLET_CODE


namespace ESRI.ArcGIS.Mobile.Client.ArcGisOnlineServices
{
    /// <summary>
    /// Helper class used to issue various requests to ArcGIS Online.
    /// </summary>
    internal class ArcGisOnlineConnection
    {        
        /// <summary>
        /// Gets a flag indicating whether the connection has a valid token.
        /// </summary>
        public bool IsSignedIn
        {
            get { return !String.IsNullOrEmpty(_token); }
        }
        
        /// <summary>
        /// Connects to the ArcGIS Online server and obtains a token for subsequent
        /// queries/operations.
        /// </summary>
        /// <param name="credentials"></param>
        /// <returns></returns>
        public bool SignIn(TokenCredential credentials)
        {
            if (this.IsSignedIn)
            {
                SignOut();
            }
            
            GenerateTokenResponse tokenResponse = null;
            
            // First obtain a token using the credentials.
            try
            {
                tokenResponse = ArcGisOnlineConnection.GenerateToken(credentials);
                if (tokenResponse == null)
                    return false;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(ex.Message);
                return false;
            }
            
            // Get information about the user.
            User user = null;
            try
            {
                user = ArcGisOnlineConnection.GetUserInfo(credentials.UserName, tokenResponse.Token);
                if (user == null)
                    return false;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(ex.Message);
                return false;
            }
            
            _credentials = credentials;
            _token = tokenResponse.Token;
            _user = user;
            
            return true;
        }
        
        /// <summary>
        /// Disconnects from the ArcGIS Online server.
        /// </summary>
        public void SignOut()
        {
            _token = null;
            _credentials = null;
            _user = null;
        }
        
        /// <summary>
        /// Gets the information about the currently signed in user.
        /// </summary>
        public User User
        {
            get { return _user; }
        }
        
        /// <summary>
        /// Returns a list of windows mobile packages in a given group that are 
        /// the currently signed in user has access to.
        /// </summary>
        /// <param name="groupId"></param>
        /// <returns></returns>
        public IList<ContentItem> GetMobilePackages(string groupId)
        {
            if (!IsSignedIn)
                return null;
            
            bool done = false;
            int start = 1;
            int maxCount = 10;
            List<ContentItem> items = new List<ContentItem>();
            
            do
            {
                try
                {
                    SearchResponse searchResult = ArcGisOnlineConnection.GetWindowsMobilePackages(groupId, start, maxCount, _token);
                    foreach (ContentItem item in searchResult.Results)
                    {
                        items.Add(item);
                    }
                    
                    if (searchResult.NextStart < 0 || searchResult.NextStart > searchResult.Total)
                        done = true;
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine(ex.Message);
                    return null;
                }      
            } while (!done);
            
            return items;
        }
        
        /// <summary>
        /// Downlods the data component of an item from the ArcGIS Online server
        /// and saves it to a given directory. 
        /// </summary>
        /// <param name="item">The item to download.</param>
        /// <param name="outputDirectory">The directory to save the item to.</param>
        /// <param name="itemPath">Full path of the downloaded file.</param>
        /// <returns>True if the item was successfully downloaded; otherwise, false.</returns>
        public bool GetItemData(ContentItem item, string outputDirectory, out string itemPath)
        {
            itemPath = null;
            
            if (item == null)
                return false;
            
            itemPath = Path.Combine(outputDirectory, item.Item);
            
            try
            {
                GetItemData(item.Id, _token, itemPath);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(ex.Message);
                return false;
            }
            
            return true;
        }
        
        /// <summary>
        /// Gets the location of the ArcGIS Online server. E.g., 
        /// www.arcgisonline.com.
        /// </summary>
        internal static string ArcGisOnlineLocation
        {
            get 
            {
                if (_location == null)
                {
                    Microsoft.Win32.RegistryKey mobileKey = Microsoft.Win32.Registry.LocalMachine.OpenSubKey(@"SOFTWARE\ESRI\Mobile10.0");
                    if (mobileKey != null)
                    {
                        _location = (string)mobileKey.GetValue("ArcGISOnlineLocation", null);
                    }
                    
                    if (String.IsNullOrEmpty(_location))
                        _location = "www.arcgisonline.com";
                }
                return _location;
            }
        }
        
        /// <summary>
        /// Issues a 'generateToken' request to the ArcGIS Online server.
        /// </summary>
        /// <param name="credentials">ArcGIS Online credentials.</param>
        /// <returns>Generate token response.</returns>
        internal static GenerateTokenResponse GenerateToken(TokenCredential credentials)
        {
            string url = String.Format("https://{0}/generateToken?f=json&client=referer&referer={1}&username={2}&password={3}",
                                       ArcGisOnlineLocation,
                                       _referer,
                                       credentials.UserName,
                                       credentials.Password
                                       );
            
            string response = RequestJSON(url);
            CheckForJsonException(response);
            
            return Deserialize<GenerateTokenResponse>(response);
        }
        
        /// <summary>
        /// Issues a 'user' request to the ArcGIS Online server to retrieve 
        /// information about a given user.
        /// </summary>
        /// <param name="username">The username to request the information for.</param>
        /// <param name="token">Security token.</param>
        /// <returns>User response.</returns>
        internal static User GetUserInfo(string username, string token)
        {
            string url = String.Format("http://{0}/community/users/{1}?f=json", ArcGisOnlineLocation, username);
            
            string response = RequestJSON(url, _referer, token);
            CheckForJsonException(response);
            
            return Deserialize<User>(response);
        }
        
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
        {
            string url = String.Format("http://{0}/search?f=json&q=group:{1} AND type:\"Windows Mobile Package\"&start={2}&num={3}",
                                       ArcGisOnlineLocation, 
                                       groupId,
                                       start, 
                                       maxCount
                                       );
            
            string response = RequestJSON(url, _referer, token);
            CheckForJsonException(response);
            
            return Deserialize<SearchResponse>(response);
        }
        
        /// <summary>
        /// Downlods the data component of an item from the ArcGIS Online server
        /// and saves it to a file.
        /// </summary>
        /// <param name="itemId">The item to download.</param>
        /// <param name="token">Security token.</param>
        /// <param name="outputFilePath">Path of the file to save the item to.</param>
        internal static void GetItemData(string itemId, string token, string outputFilePath)
        {
            string url = String.Format("http://{0}/content/items/{1}/data?f=unchanged", ArcGisOnlineLocation, itemId);
            
            if (!String.IsNullOrEmpty(token))
                url += String.Format("&token={0}", token);
            
            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(url);
            request.Timeout = 0xea60;
            if (!String.IsNullOrEmpty(_referer))
                request.Referer = _referer;
            
            WebResponse response = null;
            Stream resultStream = null;
            try
            {
                response = request.GetResponse();
                resultStream = response.GetResponseStream();
                ESRI.ArcGIS.Mobile.Client.Utility.WriteStreamToFile(resultStream, outputFilePath);
            }
            finally
            {
                if (response != null) response.Close();
                if (resultStream != null) resultStream.Close();
            }
        }
        
        private static T Deserialize<T>(string value)
        {
            JavaScriptSerializer serializer = new JavaScriptSerializer();
            T col = (T)serializer.Deserialize<T>(value);
            return col;
        }
        
        private static string RequestJSON(string url)
        {
            return RequestJSON(url, null, null);
        }
        
        private static string RequestJSON(string url, string referer, string token)
        {
            if (!String.IsNullOrEmpty(token))
                url += String.Format("&token={0}", token);
            
            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(url);
            request.Timeout = 0xea60;
            if (!String.IsNullOrEmpty(referer))
                request.Referer = referer;
            
            string result = null;
            WebResponse response = request.GetResponse();
            if (response == null)
                throw new JsonException(500, Properties.Resources.WebResponseError);
            
            using (StreamReader reader = new StreamReader(response.GetResponseStream()))
            {
                result = reader.ReadToEnd();
            }
            
            return result;
        }
        
        private static void CheckForJsonException(string response)
        {
            if (String.IsNullOrEmpty(response))
                throw new JsonException(500, Properties.Resources.WebResponseError);
            
            // Read the content.
            JavaScriptSerializer jsonSerilaizer = new JavaScriptSerializer();
            
            JsonExceptionInfo exception = Deserialize<JsonExceptionInfo>(response);
            if (exception != null && exception.Error != null)
                throw exception.Error;
        }
    }
}
#endif //TABLET CODE