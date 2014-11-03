//
//  CurioSDKTests.m
//  CurioSDKTests
//
//  Created by Harun Esur on 17/09/14.
//  Copyright (c) 2014 Turkcell. All rights reserved.
//

#import "CurioSDK.h"
#import <XCTest/XCTest.h>

@interface CurioSDKTests : XCTestCase

@end


@implementation CurioSDKTests


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

- (void)testStartSession {
    
   [[CurioDBToolkit shared] purgeActions];

   [[CurioSDK shared] startSession];
   
}


@end
