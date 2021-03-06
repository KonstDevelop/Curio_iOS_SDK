//
//  CurioAction.m
//  CurioSDK
//
//  Changed by Can Ciloglu on 30/01/15.
//  Created by Harun Esur on 18/09/14.
//  Copyright (c) 2014 Turkcell. All rights reserved.
//

#import "CurioSDK.h"


/**
 
    All stored action records are serialized within this object
    in saving and retrieving.
 
    This object already contains smart functions to automatically
    create various types of action objects like startSession or endSession.
 
 */
@implementation CurioAction


- (id) init {
    self = [super init];
    if (self) {
        
    }
    
    return self;
}


- (id) init:(NSString *) aId
       type:(NSUInteger) type
      stamp:(NSString *) stamp
      title:(NSString *) title
       path:(NSString *) path
    hitCode:(NSString *) hitCode
   eventKey:(NSString *) eventKey
 eventValue:(NSString *) eventValue {
    self = [self init];
    if (self) {
        _aId = aId;
        _actionType = (int)type;
        _stamp = stamp;
        _title = title;
        _path = path;
        _hitCode = hitCode;
        _eventKey = eventKey;
        _eventValue = eventValue;
        _isOnline = [[CurioNetwork shared] isOnline] ? CS_NSN_TRUE : CS_NSN_FALSE;
        _properties = [NSMutableDictionary new];
    }
    
    return self;
}


- (NSDictionary *) asDict {
    
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    CS_SET_DICT_IF_NOT_NIL(dict, _aId, CURKeyActionId);
    CS_SET_DICT_IF_NOT_NIL(dict, [NSNumber numberWithInt:_actionType], CURKeyActionType);
    CS_SET_DICT_IF_NOT_NIL(dict, _stamp, CURKeyTimeStamp);
    CS_SET_DICT_IF_NOT_NIL(dict, _title, CURKeyScreenDataTitle);
    CS_SET_DICT_IF_NOT_NIL(dict, _path, CURKeyScreenDataPath);
    CS_SET_DICT_IF_NOT_NIL(dict, _hitCode, CURKeyHitCode);
    CS_SET_DICT_IF_NOT_NIL(dict, _eventKey, CURKeyEventKey);
    CS_SET_DICT_IF_NOT_NIL(dict, _eventValue, CURKeyEventValue);
    CS_SET_DICT_IF_NOT_NIL(dict, _isOnline, CURKeyIsOnline);
    CS_SET_DICT_IF_NOT_NIL(dict, _properties, CURKeyProperties);
    
    return dict;
}


+ (NSDictionary *) defaultActionProperties {
    
    NSMutableDictionary *ret = [NSMutableDictionary new];
    
    CS_SET_DICT_IF_NOT_NIL(ret, [[CurioSettings shared] apiKey],CS_HTTP_PARAM_API_KEY);
    CS_SET_DICT_IF_NOT_NIL(ret, [[CurioSDK shared] sessionCode],CS_HTTP_PARAM_SESSION_CODE);
    CS_SET_DICT_IF_NOT_NIL(ret, [[CurioSettings shared] sessionTimeout],CS_HTTP_PARAM_SESSION_TIMEOUT);
    CS_SET_DICT_IF_NOT_NIL(ret, [[CurioUtil shared] vendorIdentifier],CS_HTTP_PARAM_VISITOR_CODE);
    CS_SET_DICT_IF_NOT_NIL(ret, [[CurioSettings shared] trackingCode],CS_HTTP_PARAM_TRACKING_CODE);
    CS_SET_DICT_IF_NOT_NIL(ret, [[CurioUtil shared] screenWidth],CS_HTTP_PARAM_SCREEN_WIDTH);
    CS_SET_DICT_IF_NOT_NIL(ret, [[CurioUtil shared] screenHeight],CS_HTTP_PARAM_SCREEN_HEIGHT);
    CS_SET_DICT_IF_NOT_NIL(ret, [[CurioUtil shared] deviceLanguage],CS_HTTP_PARAM_LANG);
    CS_SET_DICT_IF_NOT_NIL(ret, [[CurioNetwork shared] carrierName],CS_HTTP_PARAM_SIM_OPERATOR);
    CS_SET_DICT_IF_NOT_NIL(ret, [[CurioNetwork shared] carrierCountryCode],CS_HTTP_PARAM_SIM_COUNTRY_ISO);
    CS_SET_DICT_IF_NOT_NIL(ret, [[CurioNetwork shared] carrierName],CS_HTTP_PARAM_NETWORK_OPERATOR_NAME);
    CS_SET_DICT_IF_NOT_NIL(ret, [[CurioNetwork shared] connType],CS_HTTP_PARAM_INTERNET_CONN_TYPE);
    CS_SET_DICT_IF_NOT_NIL(ret, CURDeviceBrandName,CS_HTTP_PARAM_BRAND);
    CS_SET_DICT_IF_NOT_NIL(ret, [[CurioUtil shared] deviceModel],CS_HTTP_PARAM_MODEL);
    CS_SET_DICT_IF_NOT_NIL(ret, [[CurioUtil shared] osName],CS_HTTP_PARAM_OS_TYPE);
    CS_SET_DICT_IF_NOT_NIL(ret, [[CurioUtil shared] osVersion] ,CS_HTTP_PARAM_OS_VERSION);
    CS_SET_DICT_IF_NOT_NIL(ret, CURIO_SDK_VERSION,CS_HTTP_PARAM_SDK_VERSION);
    CS_SET_DICT_IF_NOT_NIL(ret, [[CurioUtil shared] appVersion],CS_HTTP_PARAM_APP_VERSION);
    //CS_SET_DICT_IF_NOT_NIL(ret,[[CurioResourceUtil shared] batteryState],CS_HTTP_PARAM_BATTERY_STATE);
#if !TARGET_OS_TV
    CS_SET_DICT_IF_NOT_NIL(ret,[[CurioResourceUtil shared] batteryLevel],CS_HTTP_PARAM_BATTERY_LEVEL);
    CS_SET_DICT_IF_NOT_NIL(ret,[[CurioResourceUtil shared] bluetoothState],CS_HTTP_PARAM_BLUETOOTH_STATE);
    //CS_SET_DICT_IF_NOT_NIL(ret,[[CurioResourceUtil shared] totalSpace],CS_HTTP_PARAM_TOTAL_STORAGE_SPACE);
    CS_SET_DICT_IF_NOT_NIL(ret,[[CurioResourceUtil shared] totalFreeSpace],CS_HTTP_PARAM_TOTAL_FREE_STORAGE_SPACE);
#endif
    
    
    return ret;
    
}

+ (CurioAction *) actionSendEvent:(NSString *) eventKey path:(NSString *)eventValue  {
    
    CurioAction *cAction = [[CurioAction alloc] init:[[CurioUtil shared] nanos]
                                                type:CActionTypeSendEvent
                                               stamp:[[CurioUtil shared] currentTimeMillis]
                                               title:nil path:nil hitCode:nil eventKey:eventKey eventValue:eventValue];
    
    [cAction.properties addEntriesFromDictionary:[self defaultActionProperties]];
    
    return cAction;
}

+ (CurioAction *) actionEndEvent:(NSString *) hitCode eventDuration:(NSUInteger) eventDuration{
    
    CurioAction *cAction = [[CurioAction alloc] init:[[CurioUtil shared] nanos]
                                                type:CActionTypeEndEvent
                                               stamp:[[CurioUtil shared] currentTimeMillis]
                                               title:nil path:nil hitCode:hitCode eventKey:nil eventValue:nil];
    
    [cAction.properties addEntriesFromDictionary:[self defaultActionProperties]];
    [cAction.properties setObject:[NSString stringWithFormat:@"%lu",(unsigned long)eventDuration] forKey:CURKeyEventDuration];
    
    return cAction;
}

+ (CurioAction *) actionEndScreen:(NSString *) hitCode {
    
    CurioAction *cAction = [[CurioAction alloc] init:[[CurioUtil shared] nanos]
                                                type:CActionTypeEndScreen
                                               stamp:[[CurioUtil shared] currentTimeMillis]
                                               title:nil path:nil hitCode:hitCode eventKey:nil eventValue:nil];
    
    [cAction.properties addEntriesFromDictionary:[self defaultActionProperties]];
    
    return cAction;
}

+ (CurioAction *) actionStartScreen:(NSString *) title path:(NSString *)path  {
    
    CurioAction *cAction = [[CurioAction alloc] init:[[CurioUtil shared] nanos]
                                                type:CActionTypeStartScreen
                                               stamp:[[CurioUtil shared] currentTimeMillis]
                                               title:title path:path hitCode:nil eventKey:nil eventValue:nil];
    
    [cAction.properties addEntriesFromDictionary:[self defaultActionProperties]];
    
    return cAction;
}

+ (CurioAction *) actionEndSession {

    CurioAction *cAction = [[CurioAction alloc] init:[[CurioUtil shared] nanos]
                                                type:CActionTypeEndSession
                                               stamp:[[CurioUtil shared] currentTimeMillis]
                                               title:nil path:nil hitCode:nil eventKey:nil eventValue:nil];
    
    [cAction.properties addEntriesFromDictionary:[self defaultActionProperties]];
    
    return cAction;
}

+ (CurioAction *) actionStartSession {
 
    CurioAction *cAction = [[CurioAction alloc] init:[[CurioUtil shared] nanos]
                                                type:CActionTypeStartSession
                                               stamp:[[CurioUtil shared] currentTimeMillis]
                                               title:nil path:nil hitCode:nil eventKey:nil eventValue:nil];
    
    [cAction.properties addEntriesFromDictionary:[self defaultActionProperties]];

    
    return cAction;
}

+ (CurioAction *) actionUnregister {
    
    CurioAction *cAction = [[CurioAction alloc] init:[[CurioUtil shared] nanos]
                                                type:CActionTypeUnregister
                                               stamp:[[CurioUtil shared] currentTimeMillis]
                                               title:nil path:nil hitCode:nil eventKey:nil eventValue:nil];
    
    [cAction.properties addEntriesFromDictionary:[self defaultActionProperties]];
    
    return cAction;
}

@end
