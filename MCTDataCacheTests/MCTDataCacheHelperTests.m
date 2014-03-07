/*!
*  MCTDataCacheHelperTests.m
*  MCTDataCache
*
*  Created by Skylar Schipper on 3/7/14.
*    Copyright (c) 2014 Ministry Centered Technology. All rights reserved.
*/

#import <XCTest/XCTest.h>
#import "MCTDataCacheHelpers.h"

@interface MCTDataCacheHelperTests : XCTestCase

@end

@implementation MCTDataCacheHelperTests

- (void)testSHA1String {
    NSString *test = @"http://google.com/testing";
    NSString *hash = MCTDataCacheSHA1String(test);
    XCTAssertNotNil(hash);
    XCTAssertEqualObjects(hash, @"7AFDC2714CF61C197E34DF2F7D009CDE474FCFE9");
}
- (void)testSHA1Data {
    NSData *data = [@"http://google.com/testing+data" dataUsingEncoding:NSUTF8StringEncoding];
    NSString *hash = MCTDataCacheSHA1Data(data);
    XCTAssertNotNil(hash);
    XCTAssertEqualObjects(hash, @"9B421513799A77C060B7E24F882FDA7AC5768115");
}

@end
