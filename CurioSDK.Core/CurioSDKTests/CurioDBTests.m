//
//  CurioDBTests.m
//  CurioSDK
//
//  Created by Marcus Frex on 18/09/14.
//  Copyright (c) 2014 Turkcell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "CurioSDK.h"


@interface CurioDBTests : XCTestCase

@end

@implementation CurioDBTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}



- (void)testConcurency {
    
    
    
    [[CurioDBToolkit shared] purgeActions];
    
    dispatch_queue_t my_queue = dispatch_queue_create("Test queue", NULL);
    
    for (int i=0;i<100;i++) {
        dispatch_async(my_queue, ^{
           
            
            
            CurioAction *action = [[CurioAction alloc] init:[[CurioUtil shared] nanos]
                                                       type:[[[CurioUtil shared] nanos] intValue] % 5
                                                      stamp:[[CurioUtil shared] currentTimeMillis]
                                                      title:CS_INT_AS_STRING(i) path:CS_INT_AS_STRING(i) hitCode:CS_INT_AS_STRING(i) eventKey:CS_INT_AS_STRING(i) eventValue:CS_INT_AS_STRING(i)];
            
            action.isOnline = CS_NSN_TRUE;
            [action.properties setObject:@"a" forKey:@"b"];
            [action.properties setObject:@"c" forKey:@"d"];
            
            
            XCTAssertTrue([[CurioDBToolkit shared] addAction:action],@"Failed to save action");
            
        });
    }
    
    // Wait for queue to empty
    dispatch_sync(my_queue, ^{});
    
    NSArray *objects = [[CurioDBToolkit shared] getActions:999];
    
    XCTAssertTrue(objects.count == 100,@"Concurrent object save failed: %i",objects.count );
    
    

}

@end
