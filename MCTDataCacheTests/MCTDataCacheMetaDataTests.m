/*!
*  MCTDataCacheMetaDataTests.m
*  MCTDataCache
*
*  Created by Skylar Schipper on 3/7/14.
*    Copyright (c) 2014 Ministry Centered Technology. All rights reserved.
*/

#import <XCTest/XCTest.h>
#import "MCTDataCacheMetaData.h"

@interface MCTDataCacheMetaDataTests : XCTestCase

@end

@implementation MCTDataCacheMetaDataTests

- (void)testDefaultMetaData {
    NSDictionary *defaultData = [MCTDataCacheMetaData defaultMetaDataForFile:@"test_song.mp3"];
    XCTAssertNotNil(defaultData);
    XCTAssertNotNil(defaultData[kMCTDataCacheFileName]);
    XCTAssertNotNil(defaultData[kMCTDataCacheFileExtention]);
    XCTAssertNotNil(defaultData[kMCTDataCacheMimeType]);
    XCTAssertNotNil(defaultData[kMCTDataCacheUUID]);
    XCTAssertNotNil(defaultData[kMCTDataCacheDate]);
    XCTAssertNil(defaultData[kMCTDataCacheSize]);
    XCTAssertNil(defaultData[kMCTDataCacheLastReadDate]);
    
    XCTAssertEqualObjects(defaultData[kMCTDataCacheFileName], @"test_song.mp3");
    XCTAssertEqualObjects(defaultData[kMCTDataCacheFileExtention], @"mp3");
    XCTAssertEqualObjects(defaultData[kMCTDataCacheMimeType], @"audio/mpeg");
}

- (void)testInfoUpdate {
    NSDictionary *defaultData = [MCTDataCacheMetaData defaultMetaDataForFile:@"test_song.mp3"];
    XCTAssertNotNil(defaultData);
    XCTAssertNotNil(defaultData[kMCTDataCacheFileName]);
    XCTAssertNotNil(defaultData[kMCTDataCacheFileExtention]);
    XCTAssertNotNil(defaultData[kMCTDataCacheMimeType]);
    XCTAssertNotNil(defaultData[kMCTDataCacheUUID]);
    XCTAssertNotNil(defaultData[kMCTDataCacheDate]);
    XCTAssertNil(defaultData[kMCTDataCacheSize]);
    XCTAssertNil(defaultData[kMCTDataCacheLastReadDate]);
    
    XCTAssertEqualObjects(defaultData[kMCTDataCacheFileName], @"test_song.mp3");
    XCTAssertEqualObjects(defaultData[kMCTDataCacheFileExtention], @"mp3");
    XCTAssertEqualObjects(defaultData[kMCTDataCacheMimeType], @"audio/mpeg");
    
    defaultData = [MCTDataCacheMetaData updateInfo:defaultData fileSize:1000000 readDate:[NSDate date] path:@"/test/path" hash:@"TESTOBJECTHASH"];
    
    XCTAssertNotNil(defaultData);
    XCTAssertNotNil(defaultData[kMCTDataCacheFileName]);
    XCTAssertNotNil(defaultData[kMCTDataCacheFileExtention]);
    XCTAssertNotNil(defaultData[kMCTDataCacheMimeType]);
    XCTAssertNotNil(defaultData[kMCTDataCacheUUID]);
    XCTAssertNotNil(defaultData[kMCTDataCacheDate]);
    XCTAssertNotNil(defaultData[kMCTDataCacheSize]);
    XCTAssertNotNil(defaultData[kMCTDataCacheLastReadDate]);
    XCTAssertNotNil(defaultData[kMCTDataCacheFilePath]);
    XCTAssertNotNil(defaultData[kMCTDataCacheHash]);
    
    XCTAssertEqualObjects(defaultData[kMCTDataCacheSize], @1000000);
    XCTAssertEqualObjects(defaultData[kMCTDataCacheFileName], @"test_song.mp3");
    XCTAssertEqualObjects(defaultData[kMCTDataCacheFileExtention], @"mp3");
    XCTAssertEqualObjects(defaultData[kMCTDataCacheMimeType], @"audio/mpeg");
    XCTAssertEqualObjects(defaultData[kMCTDataCacheFilePath], @"/test/path");
    XCTAssertEqualObjects(defaultData[kMCTDataCacheHash], @"TESTOBJECTHASH");
}

@end
