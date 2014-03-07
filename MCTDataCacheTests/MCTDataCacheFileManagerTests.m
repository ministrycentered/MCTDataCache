/*!
*  MCTDataCacheFileManagerTests.m
*  MCTDataCache
*
*  Created by Skylar Schipper on 3/7/14.
*    Copyright (c) 2014 Ministry Centered Technology. All rights reserved.
*/

#import <XCTest/XCTest.h>
#import "MCTDataCacheFileManager.h"
#import "MCTDataCacheMetaData.h"

@interface MCTDataCacheFileManagerTests : XCTestCase

@end

@implementation MCTDataCacheFileManagerTests

- (void)testFilePathCreation {
    NSString *hash = @"A94A8FE5CCB19BA61C4C0873D391E987982FBBD3";
    NSString *rootDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    
    MCTDataCacheFileManager *manager = [[MCTDataCacheFileManager alloc] init];
    NSError *error = nil;
    NSString *path = [manager directoryForCacheWithHash:hash error:&error];
    
    XCTAssertNotNil(path);
    XCTAssertNil(error);
    XCTAssertTrue([path hasPrefix:rootDir]);
    XCTAssertTrue([path hasSuffix:@"/MCTDataCache/1_0/A/A94A8FE5CCB19BA61C4C0873D391E987982FBBD3"]);
    
    BOOL isDir = NO;
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]);
    XCTAssertTrue(isDir);
    
    NSString *hardPath = [rootDir stringByAppendingPathComponent:@"MCTDataCache/1_0/A/A94A8FE5CCB19BA61C4C0873D391E987982FBBD3"];
    XCTAssertEqualObjects(path, hardPath); 
}
- (void)testFilePathHelper {
    XCTAssertEqualObjects([[[MCTDataCacheFileManager alloc] init] filePathForRootPath:@"test/root/path"], @"test/root/path/file.dat");
}
- (void)testFileInfoHelper {
    XCTAssertEqualObjects([[[MCTDataCacheFileManager alloc] init] infoPathForRootPath:@"test/root/path"], @"test/root/path/Info.json");
}
- (void)testPreferredMIMETypes {
    XCTAssertEqualObjects([MCTDataCacheFileManager preferedMimeTypeForFileExtention:@"png"], @"image/png");
    XCTAssertEqualObjects([MCTDataCacheFileManager preferedMimeTypeForFileExtention:@"jpg"], @"image/jpeg");
    XCTAssertEqualObjects([MCTDataCacheFileManager preferedMimeTypeForFileExtention:@"m4a"], @"audio/x-m4a");
    XCTAssertEqualObjects([MCTDataCacheFileManager preferedMimeTypeForFileExtention:@"mp3"], @"audio/mpeg");
    XCTAssertEqualObjects([MCTDataCacheFileManager preferedMimeTypeForFileExtention:@"junk"], @"application/octet-stream");
}
- (void)testWritingToCache {
    MCTDataCacheFileManager *manager = [[MCTDataCacheFileManager alloc] init];
    NSString *fileName = @"test_song.mp3";
    NSString *bundlePath = [[NSBundle bundleForClass:[self class]] pathForResource:[[fileName componentsSeparatedByString:@"."] firstObject] ofType:[fileName pathExtension]];
    
    NSError *error = nil;
    
    NSDictionary *info = [MCTDataCacheMetaData defaultMetaDataForFile:fileName];
    
    XCTAssertTrue([manager copyDataAtPath:bundlePath toHash:@"8FFD090ECBA005150B45F92CB26F5B5F1D29DAC8" info:info error:&error]);
    XCTAssertNil(error);
    
    NSError *cacheError = nil;
    MCTDataCacheObject *object = [manager cachedObjectWithHash:@"8FFD090ECBA005150B45F92CB26F5B5F1D29DAC8" error:&cacheError];
    XCTAssertNil(cacheError);
    XCTAssertNotNil(object);
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:object.filePath isDirectory:NULL]);
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:object.fileInfoPath isDirectory:NULL]);
}
- (void)testDeleteObject {
    MCTDataCacheFileManager *manager = [[MCTDataCacheFileManager alloc] init];
    NSString *fileName = @"test_song.mp3";
    NSString *bundlePath = [[NSBundle bundleForClass:[self class]] pathForResource:[[fileName componentsSeparatedByString:@"."] firstObject] ofType:[fileName pathExtension]];
    
    NSError *error = nil;
    NSDictionary *info = @{
                           @"name": fileName,
                           @"mime-type": [MCTDataCacheFileManager preferedMimeTypeForFileExtention:[fileName pathExtension]]
                           };
    
    XCTAssertTrue([manager copyDataAtPath:bundlePath toHash:@"8FFD090ECBA005150B45F92CB26F5B5F1D29DAC8" info:info error:&error]);
    XCTAssertNil(error);
    
    NSError *cacheError = nil;
    MCTDataCacheObject *object = [manager cachedObjectWithHash:@"8FFD090ECBA005150B45F92CB26F5B5F1D29DAC8" error:&cacheError];
    XCTAssertNil(cacheError);
    XCTAssertNotNil(object);
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:object.filePath isDirectory:NULL]);
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:object.fileInfoPath isDirectory:NULL]);
    
    NSError *deleteError = nil;
    XCTAssertTrue([manager deleteHash:@"8FFD090ECBA005150B45F92CB26F5B5F1D29DAC8" error:&deleteError]);
    XCTAssertNil(deleteError);
    XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:object.filePath isDirectory:NULL]);
    XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:object.fileInfoPath isDirectory:NULL]);
}
- (void)testObjectExistsInCache {
    MCTDataCacheFileManager *manager = [[MCTDataCacheFileManager alloc] init];
    NSString *fileName = @"test_song.mp3";
    NSString *bundlePath = [[NSBundle bundleForClass:[self class]] pathForResource:[[fileName componentsSeparatedByString:@"."] firstObject] ofType:[fileName pathExtension]];
    
    NSError *error = nil;
    NSDictionary *info = @{
                           @"name": fileName,
                           @"mime-type": [MCTDataCacheFileManager preferedMimeTypeForFileExtention:[fileName pathExtension]]
                           };
    
    XCTAssertTrue([manager copyDataAtPath:bundlePath toHash:@"8FFD090ECBA005150B45F92CB26F5B5F1D29DAC8" info:info error:&error]);
    XCTAssertNil(error);
    
    NSError *cacheError = nil;
    MCTDataCacheObject *object = [manager cachedObjectWithHash:@"8FFD090ECBA005150B45F92CB26F5B5F1D29DAC8" error:&cacheError];
    XCTAssertNil(cacheError);
    XCTAssertNotNil(object);
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:object.filePath isDirectory:NULL]);
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:object.fileInfoPath isDirectory:NULL]);
    
    NSError *readError = nil;
    XCTAssertTrue([manager cacheExitsForHash:@"8FFD090ECBA005150B45F92CB26F5B5F1D29DAC8" error:&readError]);
    XCTAssertNil(readError);
    NSError *deleteError = nil;
    XCTAssertTrue([manager deleteHash:@"8FFD090ECBA005150B45F92CB26F5B5F1D29DAC8" error:&deleteError]);
    XCTAssertNil(deleteError);
    
    XCTAssertFalse([manager cacheExitsForHash:@"8FFD090ECBA005150B45F92CB26F5B5F1D29DAC8" error:&readError]);
    XCTAssertNil(readError);
}
- (void)testInfoFilePaths {
    MCTDataCacheFileManager *manager = [[MCTDataCacheFileManager alloc] init];
    NSSet *contents = [manager infoFilePaths];
    XCTAssertNotNil(contents);
}

@end
