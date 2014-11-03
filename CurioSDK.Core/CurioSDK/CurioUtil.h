//
//  CurioUtil.h
//  CurioSDK
//
//  Created by Harun Esur on 18/09/14.
//  Copyright (c) 2014 Turkcell. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <uuid/uuid.h>

@interface CurioUtil : NSObject

/**
 Returns shared instance of CurioUtil
 
 @return CurioUtil shared instance
 */
+ (CS_INSTANCETYPE) shared;

/**
 *  Generates UUID based on RFC 4122 with random
 *
 *  @return Generated Random UUID
 */
- (NSString *) uuidRandom;

/**
    Generates UUID based on RFC 4122: A Universally Unique IDentifier (UUID) URN Namespace, 
    section 4.2 "Algorithms for Creating a Time-Based UUID"
 
 @return Generated UUID v1
 */
- (NSString *) uuidV1;


/**
    Returns java compatible time in millis
 
    @return Time in millis
 */
- (NSString *) currentTimeMillis;

/**
    Returns nanotime
 
    @return Time in nanotime
 */
- (NSString *) nanos;

/**
    Encodes string to URL compatible version
 
    @return URL compatible string
 */
- (NSString *)urlEncode:(NSString *)input;


/**
    Serializes object to JSON format
 
    @return Formatted JSON string 
 */
- (NSString *)toJson:(id) object enablePercentEncoding:(BOOL) percentEncoding;


/**
    De-serializes JSON string to object
 
    @return De-serialized object from JSON string
 */
- (id) fromJson:(NSString *) json percentEncoded:(BOOL) percentEncoded;

/**
    Returns device identifier for Vendor
 */
- (NSString *) vendorIdentifier;

/**
    Returns device screen width
 */
- (NSNumber *) screenWidth;

/**
    Returns device screen height
 */
- (NSNumber *) screenHeight;

/**
    Returns device language
 */
- (NSString *) deviceLanguage;

/**
    Returns device model 
 */
- (NSString *) deviceModel;

/**
    Returns operating system name
 */
- (NSString *) osName;

/**
    Returns operating system version
 */
- (NSString *) osVersion;

/**
    Returns version of app
 */
- (NSString *) appVersion;
@end
