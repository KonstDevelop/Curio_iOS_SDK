//
//  CurioUtil.m
//  CurioSDK
//
//  Changed by Can Ciloglu on 30/01/15.
//  Created by Harun Esur on 18/09/14.
//  Copyright (c) 2014 Turkcell. All rights reserved.
//

#import "CurioSDK.h"
#import <mach/mach.h>
#include <mach/mach_time.h>




@implementation CurioUtil

+ (CS_INSTANCETYPE) shared {
    
    static dispatch_once_t once;
    
    static id instance;
    
    dispatch_once(&once, ^{
        instance = [self new];
    });
    
    return instance;
}

- (NSString *) uuidRandom {
    
    uuid_t uuid;
    uuid_string_t out;
    
    uuid_generate_random(uuid);
    uuid_unparse_lower(uuid, out);
    
    
    return [NSString stringWithFormat:@"%s",out];
}

- (NSString *) uuidV1 {
    
    uuid_t uuid;
    uuid_string_t out;
    
    uuid_generate_time(uuid);
    uuid_unparse_lower(uuid, out);
    

    return [NSString stringWithFormat:@"%s",out];
}

- (NSString *) appVersion {
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        
    return [NSString stringWithFormat:@"%@", version];
    
}

- (NSString *) osName {
#if TARGET_OS_TV
    return  @"TVOS";
#else
    return @"iOS";
#endif
}

- (NSString *) osVersion {
    return  [[UIDevice currentDevice] systemVersion];
}


- (NSString *) deviceModel {
    return  [[UIDevice currentDevice] model];
}


- (NSString *) deviceLanguage {
   return [[NSLocale preferredLanguages] objectAtIndex:0];
}

- (NSNumber *) screenWidth {
    
    float scaleFactor = [[UIScreen mainScreen] scale];
    
    return [NSNumber numberWithInt:[[UIScreen mainScreen] bounds].size.width * scaleFactor];
}

- (NSNumber *) screenHeight {
    
    float scaleFactor = [[UIScreen mainScreen] scale];
    
    return [NSNumber numberWithInt:[[UIScreen mainScreen] bounds].size.height * scaleFactor];
}


- (NSString *) vendorIdentifier {
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

- (NSString *) currentTimeMillis {
    
    return [NSString stringWithFormat:@"%lld",(long long)([[NSDate date] timeIntervalSince1970] * 1000)];
}

- (NSString *) nanos {
        mach_timebase_info_data_t info;
        mach_timebase_info(&info);
        uint64_t now = mach_absolute_time();
        now *= info.numer;
        now /= info.denom;
        return [NSString stringWithFormat:@"%lld",now];
}


- (NSString *)urlEncode:(NSString *)input {
    
    if (input == nil) {
        return @"";
    }
    
    NSMutableString *output = [NSMutableString string];
    //buffer for illegal input string types. eg nsnumber
    NSString *str = [NSString stringWithFormat:@"%@", input];
    const unsigned char *source = (const unsigned char *)[str UTF8String];
    unsigned long sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

-(NSString *)urlDecode:(NSString *)input {
    
    
return [[input
      stringByReplacingOccurrencesOfString:@"+" withString:@" "]
     stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
}

- (NSString *)toJson:(id) object enablePercentEncoding:(BOOL) percentEncoding {
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:kNilOptions
                                                         error:&error];
    
    NSString *pJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    return percentEncoding ? [self urlEncode:pJson] : pJson;
}

- (id) fromJson:(NSString *) json percentEncoded:(BOOL) percentEncoded {
    
    NSString *decodedJson = [self urlDecode:json];
    
    NSString *js = !percentEncoded ? json  : decodedJson;
    
    NSError *error;
    
    NSData *pData = [js dataUsingEncoding:NSUTF8StringEncoding];
    
    
    id obj = [NSJSONSerialization JSONObjectWithData:pData
                                             options:kNilOptions
                                               error:&error];

    
    return obj;
}

- (id) fromJson:(NSString *) json percentEncoded:(BOOL) percentEncoded error:(NSError **)error{
    
    NSString *decodedJson = [self urlDecode:json];
    
    NSString *js = !percentEncoded ? json  : decodedJson;
    
    NSData *pData = [js dataUsingEncoding:NSUTF8StringEncoding];
    
    return [NSJSONSerialization JSONObjectWithData:pData
                                           options:kNilOptions
                                             error:error];
    
}

- (NSString *) dictToPostBody:(NSDictionary *) dict {
    
    NSMutableString *vars_str = [NSMutableString new];
    if (dict != nil && dict.count > 0) {
        BOOL first = YES;
        for (NSString *key in dict) {
            if (!first) {
                [vars_str appendString:@"&"];
            }
            first = NO;
            
            [vars_str appendString:[self urlEncode:key]];
            [vars_str appendString:@"="];
            [vars_str appendString:[self urlEncode:[dict valueForKey:key]]];
        }
    }
    
    return vars_str;
}



@end
