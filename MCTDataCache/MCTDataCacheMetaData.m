/*!
 * MCTDataCacheMetaData.m
 *
 * Copyright (c) 2014 Ministry Centered Technology
 *
 * Created by Skylar Schipper on 3/7/14
 */

#import "MCTDataCacheMetaData.h"
#import "MCTDataCacheFileManager.h"

@interface MCTDataCacheMetaData ()

@end

@implementation MCTDataCacheMetaData

+ (NSDictionary *)defaultMetaDataForFile:(NSString *)fileName {
    NSString *fileExt = [fileName pathExtension];
    NSString *mimeType = [MCTDataCacheFileManager preferedMimeTypeForFileExtention:fileExt];
    return @{
             kMCTDataCacheFileName: fileName,
             kMCTDataCacheMimeType: mimeType,
             kMCTDataCacheFileExtention: fileExt,
             kMCTDataCacheDate: @([[NSDate date] timeIntervalSince1970]),
             kMCTDataCacheUUID: [[NSUUID UUID] UUIDString],
             };
}
+ (NSDictionary *)updateInfo:(NSDictionary *)info fileSize:(uint64_t)fileSize readDate:(NSDate *)readDate path:(NSString *)path hash:(NSString *)hash {
    NSMutableDictionary *update = [info mutableCopy];
    update[kMCTDataCacheSize] = @(fileSize);
    update[kMCTDataCacheLastReadDate] = @([readDate timeIntervalSince1970]);
    update[kMCTDataCacheFilePath] = path;
    update[kMCTDataCacheHash] = hash;
    return [update copy];
}
+ (NSDictionary *)infoForPath:(NSString *)path error:(NSError **)error {
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (data) {
        return [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
    }
    return nil;
}
+ (NSArray *)infoForPaths:(NSSet *)paths {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:paths.count];
    for (NSString *path in paths) {
        NSDictionary *info = [self infoForPath:path error:nil];
        if (info) {
            [array addObject:info];
        }
    }
    return array;
}

@end

NSString * const kMCTDataCacheFilePath = @"path";
NSString * const kMCTDataCacheFileName = @"fileName";
NSString * const kMCTDataCacheMimeType = @"mimeType";
NSString * const kMCTDataCacheFileExtention = @"fileExtention";
NSString * const kMCTDataCacheDate = @"saveDate";
NSString * const kMCTDataCacheUUID = @"UUID";
NSString * const kMCTDataCacheSize = @"size";
NSString * const kMCTDataCacheLastReadDate = @"readDate";
NSString * const kMCTDataCacheHash = @"pathHash";
