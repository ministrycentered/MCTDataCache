/*!
 * MCTDataCacheMetaData.h
 *
 * Copyright (c) 2014 Ministry Centered Technology
 *
 * Created by Skylar Schipper on 3/7/14
 */

#ifndef MCTDataCacheMetaData_h
#define MCTDataCacheMetaData_h

@import Foundation;

@interface MCTDataCacheMetaData : NSObject

+ (NSDictionary *)defaultMetaDataForFile:(NSString *)fileName;
+ (NSDictionary *)updateInfo:(NSDictionary *)info fileSize:(uint64_t)fileSize readDate:(NSDate *)readDate path:(NSString *)path hash:(NSString *)hash;

+ (NSDictionary *)infoForPath:(NSString *)path error:(NSError **)error;
+ (NSArray *)infoForPaths:(NSSet *)paths;

@end

OBJC_EXTERN NSString * const kMCTDataCacheFilePath;
OBJC_EXTERN NSString * const kMCTDataCacheFileName;
OBJC_EXTERN NSString * const kMCTDataCacheMimeType;
OBJC_EXTERN NSString * const kMCTDataCacheFileExtention;
OBJC_EXTERN NSString * const kMCTDataCacheHash;
OBJC_EXTERN NSString * const kMCTDataCacheDate;
OBJC_EXTERN NSString * const kMCTDataCacheUUID;
OBJC_EXTERN NSString * const kMCTDataCacheSize;
OBJC_EXTERN NSString * const kMCTDataCacheLastReadDate;

#endif
