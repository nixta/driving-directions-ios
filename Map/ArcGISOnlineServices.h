//
//  ArcGISOnlineServices.h
//  ArcGISMobile
//
//  Created by Mark Dostal on 2/22/10.
//  Copyright 2010 ESRI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ArcGIS+App.h"
#import "ContentItem.h"

//
// JsonException
//
@interface JsonException : NSObject {
    NSInteger   _code;
    NSString    *_message;
}

@property (nonatomic, assign) NSInteger     code;
@property (nonatomic, retain) NSString      *message;

@end

//
// JSonExceptionInfo
//
@interface JsonExceptionInfo : NSObject {
    JsonException* _error;
}
@property (nonatomic, retain) JsonException *error;

@end

//
// TokenResponse
//
// Class the represents the JSON response from the 'generateToken' request.
//
@interface TokenResponse : NSObject <AGSCoding> {
    NSString    *_token;
    NSInteger   _expires;
}
@property (nonatomic, retain) NSString  *token;
@property (nonatomic, assign) NSInteger expires;

@end

//
// User
//
// Class the represents the JSON response when requesting information 
// regarding about a specific user.
//
@interface User : NSObject <AGSCoding> {
    NSString        *_userName;
    NSString        *_fullName;
    NSString        *_description;
    NSString        *_email;
    NSString        *_organization;
    NSString        *_defaultGroupId;
    NSMutableArray  *_groups;
}

@property (nonatomic, retain) NSString          *userName;
@property (nonatomic, retain) NSString          *fullName;
@property (nonatomic, retain) NSString          *description;
@property (nonatomic, retain) NSString          *email;
@property (nonatomic, retain) NSString          *organization;
@property (nonatomic, retain) NSString          *defaultGroupId;
@property (nonatomic, retain) NSMutableArray    *groups;

@end

//
// Group
//
@interface Group : NSObject <AGSCoding> {
    NSString        *_groupId;
    NSString        *_title;
    NSString        *_description;
    NSString        *_snippet;
    NSString        *_phone;
    NSString        *_thumbnail;
    NSString        *_owner;
    double          _created;
    NSString        *_featuredItemsId;
    bool            _isPublic;
    bool            _isInvitationOnly;
    bool            _isOrganization;
    NSMutableArray  *_members;
    NSMutableArray  *_tags;
    UIImage         *_groupIcon;
}

@property (nonatomic, retain) NSString          *groupId;
@property (nonatomic, retain) NSString          *title;
@property (nonatomic, retain) NSString          *description;
@property (nonatomic, retain) NSString          *snippet;
@property (nonatomic, retain) NSString          *phone;
@property (nonatomic, retain) NSString          *thumbnail;
@property (nonatomic, retain) NSString          *owner;
@property (nonatomic, assign) double            created;
@property (nonatomic, retain) NSString          *featuredItemsId;
@property (nonatomic, assign) bool              isPublic;
@property (nonatomic, assign) bool              isInvitationOnly;
@property (nonatomic, assign) bool              isOrganization;
@property (nonatomic, retain) NSMutableArray    *members;
@property (nonatomic, retain) NSMutableArray    *tags;
@property (nonatomic, retain) UIImage           *groupIcon;

-(NSString *)groupThumbnailURLString;

@end

//
// Member - Class representing the members of a group
// Note that this is different from class Users
//
@interface Member : NSObject <AGSCoding> {
    NSString *_userName;
    NSString *_memberType;
}

@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *memberType;

@end

//
// SearchResults - Class representing the search results.
//
// Not Yet Defined.
//
@interface SearchResults : NSObject <AGSCoding> {
}

@end

//
// SearchResponse
//
@interface SearchResponse : NSObject <AGSCoding> {
    NSInteger _total;
    NSInteger _start;
    NSInteger _num;
    NSInteger _nextStart;
    //    NSMutableArray  *_results;
}

// This represents to total number of results.
@property (nonatomic, assign) NSInteger total;

// This represents the index of the first result in the search response.
@property (nonatomic, assign) NSInteger start;

//This represents the number of results in the search response.
@property (nonatomic, assign) NSInteger num;

// This represents the start index of the item in the next result set. 
@property (nonatomic, assign) NSInteger nextStart;

// The collection of results in this search response.
//@property (nonatomic, retain) NSMutableArray *results;

@end

//
// ContentFolder
//
@interface ContentFolder : NSObject <AGSCoding> {
    NSString    *_userName;
    NSString    *_folderId;
    NSString    *_title;
    double      _created;
}

@property (nonatomic, retain) NSString  *userName;
@property (nonatomic, retain) NSString  *folderId;
@property (nonatomic, retain) NSString  *title;
@property (nonatomic, assign) double    created;

@end

//
// Utility
//
@interface Utility : NSObject
/// <summary>
/// Returns the user-friendly name of an item from ArcGIS Online.
/// </summary>
/// <param name="item">The item from ArcGIS Online.</param>
/// <returns>User-friendly name for the item.</returns>
+ (NSString *)getContentItemDisplayString:(ContentItem *)item;

@end
