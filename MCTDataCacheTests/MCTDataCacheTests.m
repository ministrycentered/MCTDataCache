//
//  MCTDataCacheTests.m
//  MCTDataCacheTests
//
//  Created by Skylar Schipper on 3/7/14.
//  Copyright (c) 2014 Ministry Centered Technology. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MCTDataCache.h"

@interface MCTDataCacheTests : XCTestCase

@end

@implementation MCTDataCacheTests

- (void)testCacheSizing {
    XCTAssertTrue([[MCTDataCacheController sharedCache] cacheSizeInBytes] > 0);
}
- (void)testCacheSizeOversized {
    [[MCTDataCacheController sharedCache] setMaxCacheSize:MCTDataCacheSize_500MB];
    XCTAssertFalse([[MCTDataCacheController sharedCache] cacheIsOversized]);
    [[MCTDataCacheController sharedCache] setMaxCacheSize:1];
    XCTAssertTrue([[MCTDataCacheController sharedCache] cacheIsOversized]);
    [[MCTDataCacheController sharedCache] setMaxCacheSize:MCTDataCacheSize_500MB];
}

@end
