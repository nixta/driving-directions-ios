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

@interface NSDictionary (NSDictionary_Additions)

/** Returns the value associated with key from dict.  If the
 value is equal to <code>[NSNull null]</code>, the method will return <code>nil</code>.
 @since 1.0
 @param dict Dictionary to retrieve the object from.
 @param key Key corresponding to the value to retrieve.
 @since 1.0
 */
+(id)safeGetObjectFromDictionary:(NSDictionary *)dict 
                         withKey:(NSString *)key;

/** Sets the object into the dictionary with the given key.  If the
 object is <code>nil</code>, will set <code>[NSNull null]</code> into the dictionary.
 @param dict Dictionary to add the key/object pair to.
 @param object The object to place in the dictionary.
 @param key The key in which to pair with @p object in the dictionary.
 @since 1.0
 */
+(void)safeSetObjectInDictionary:(NSMutableDictionary *)dict
                          object:(NSObject *)object
                         withKey:(NSString *)key;



@end
