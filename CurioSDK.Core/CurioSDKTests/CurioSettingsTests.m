//
//  CSSettingsTest.m
//  CurioSDK
//
//  Created by Marcus Frex on 18/09/14.
//  Copyright (c) 2014 Turkcell. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CurioSDK.h"


@interface CurioSettingsTests : XCTestCase

@end

@implementation CurioSettingsTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testValues
{
    
   
    
    CurioSettings *css = [CurioSettings shared];
    
    XCTAssertTrue([css.serverUrl isEqualToString:@"https://curiotest.turkcell.com.tr/api/v2"], @"Server URL has read invalid: %@",css.serverUrl);
    XCTAssertTrue([css.apiKey isEqualToString:@"a1578e903eff11e4aacd5119157960aa"], @"API key has read invalid: %@", css.apiKey);
    XCTAssertTrue([css.trackingCode isEqualToString:@"2OTP5B2R"], @"Tracking code has read invalid: %@",css.trackingCode);
    
}

@end
