/*!
 * MCTDataCacheFileManager.h
 *
 * Copyright (c) 2014 Ministry Centered Technology
 *
 * Created by Skylar Schipper on 3/7/14
 */

#ifndef MCTDataCacheFileManager_h
#define MCTDataCacheFileManager_h

#import <Foundation/Foundation.h>
#import "MCTDataCacheObject.h"

@interface MCTDataCacheFileManager : NSObject

- (MCTDataCacheObject *)cachedObjectWithHash:(NSString *)hash error:(NSError **)error;

- (BOOL)cacheExitsForHash:(NSString *)hash error:(NSError **)error;

- (NSString *)directoryForCacheWithHash:(NSString *)hash error:(NSError **)error;
- (BOOL)createDirectoryForPath:(NSString *)path error:(NSError **)error;

+ (NSString *)rootCacheDirectoryPath;
+ (NSString *)tmpFilePath;

- (NSString *)filePathForRootPath:(NSString *)path;
- (NSString *)infoPathForRootPath:(NSString *)path;

+ (NSString *)preferedMimeTypeForFileExtention:(NSString *)extention;

- (BOOL)writeData:(NSData *)data toHash:(NSString *)hash info:(NSDictionary *)info error:(NSError **)error;
- (BOOL)copyDataAtPath:(NSString *)copyPath toHash:(NSString *)hash info:(NSDictionary *)info error:(NSError **)error;

- (BOOL)deleteHash:(NSString *)hash error:(NSError **)error;

- (NSSet *)infoFilePaths;

- (BOOL)flushCacheWithError:(NSError **)error;

+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL error:(NSError **)error;

@end


#endif
