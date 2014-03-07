/*!
*  MCTDataCacheURLFormatterTests.m
*  MCTDataCache
*
*  Created by Skylar Schipper on 3/7/14.
*    Copyright (c) 2014 Ministry Centered Technology. All rights reserved.
*/

#import <XCTest/XCTest.h>
#import "MCTDataCacheURLFormatter.h"

@interface MCTDataCacheURLFormatterTests : XCTestCase

@end

@implementation MCTDataCacheURLFormatterTests

- (void)testURLFormatter {
    NSString *fileHashForURL = [MCTDataCacheURLFormatter fileHashForURL:[NSURL URLWithString:@"https://s3.amazonaws.com/planning_center/be7264ea3797c2e861a34f7fd4f00e53?AWSAccessKeyId=AKIAJDLVAQB5O4UL2REA&Expires=1394230923&Signature=fOiX816y3cF3ywO3MAD%2BVlw0o9g%3D&response-content-disposition=attachment%3B%20filename%3D%221-08%20Forever%20Reign.m4a%22&response-content-type=audio%2FMP4A-LATM"]];
    XCTAssertNotNil(fileHashForURL);
    XCTAssertEqualObjects(fileHashForURL, @"DD45834BB1514FD9610BAB0DA927E8B0AF184C1E");
}
- (void)testURLFormatterWithParams {
    NSDictionary *params = nil;
    NSString *fileHashForURL = [MCTDataCacheURLFormatter fileHashForURL:[NSURL URLWithString:@"https://s3.amazonaws.com/planning_center/be7264ea3797c2e861a34f7fd4f00e53?AWSAccessKeyId=AKIAJDLVAQB5O4UL2REA&Expires=1394230923&Signature=fOiX816y3cF3ywO3MAD%2BVlw0o9g%3D&response-content-disposition=attachment%3B%20filename%3D%221-08%20Forever%20Reign.m4a%22&response-content-type=audio%2FMP4A-LATM"] params:&params];
    XCTAssertNotNil(fileHashForURL);
    XCTAssertEqualObjects(fileHashForURL, @"DD45834BB1514FD9610BAB0DA927E8B0AF184C1E");
    
    XCTAssertNotNil(params);
    XCTAssertEqualObjects(params[@"filename"], @"1-08 Forever Reign.m4a");
}

@end
