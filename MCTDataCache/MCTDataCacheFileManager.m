/*!
 * MCTDataCacheFileManager.m
 *
 * Copyright (c) 2014 Ministry Centered Technology
 *
 * Created by Skylar Schipper on 3/7/14
 */

#if TARGET_OS_IPHONE
    #import <MobileCoreServices/MobileCoreServices.h>
#else

#endif

#import "MCTDataCacheFileManager.h"
#import "MCTDataCacheHelpers.h"
#import "MCTDataCacheMetaData.h"

@interface MCTDataCacheFileManager ()

@end

@implementation MCTDataCacheFileManager

- (MCTDataCacheObject *)cachedObjectWithHash:(NSString *)hash error:(NSError **)error {
    NSString *rootPath = [self directoryForCacheWithHash:hash error:error];
    if (!rootPath) {
        return nil;
    }
    return [[MCTDataCacheObject alloc] initWithHash:hash rootPath:rootPath filePath:[self filePathForRootPath:rootPath] fileInfoPath:[self infoPathForRootPath:rootPath]];
}
- (BOOL)cacheExitsForHash:(NSString *)hash error:(NSError **)error {
    MCTDataCacheObject *object = [self cachedObjectWithHash:hash error:error];
    if (!object) {
        return NO;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:object.filePath isDirectory:NULL]) {
        return NO;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:object.fileInfoPath isDirectory:NULL]) {
        return NO;
    }
    return YES;
}


- (NSString *)directoryForCacheWithHash:(NSString *)hash error:(NSError **)error {
    NSString *baseDirectory = [hash substringToIndex:1];
    NSString *rootDirectory = [[self class] rootCacheDirectoryPath];
    NSString *path = [[rootDirectory stringByAppendingPathComponent:baseDirectory] stringByAppendingPathComponent:hash];
    if ([self createDirectoryForPath:path error:error]) {
        return path;
    }
    return nil;
}
- (BOOL)createDirectoryForPath:(NSString *)path error:(NSError **)error {
    BOOL directory = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&directory]) {
        return directory;
    }
    return [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:error];
}

+ (NSString *)mct_cacheDirectory {
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    rootPath = [rootPath stringByAppendingPathComponent:@"MCTDataCache"];
    return rootPath;
}
+ (NSString *)rootCacheDirectoryPath {
    static NSString *rootPath;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        rootPath = [[self class] mct_cacheDirectory];
        rootPath = [rootPath stringByAppendingPathComponent:MCTDataCacheVersionPathString()];
    });
    return rootPath;
}
+ (NSString *)tmpFilePath {
    static NSString *rootPath;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        rootPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        rootPath = [rootPath stringByAppendingPathComponent:@"MCTDataCache_tmp"];
    });
    if (![[NSFileManager defaultManager] fileExistsAtPath:rootPath isDirectory:NULL]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:rootPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return rootPath;
}

#pragma mark -
#pragma mark - Path Helpers
- (NSString *)filePathForRootPath:(NSString *)path {
    return [path stringByAppendingPathComponent:@"file.dat"];
}
- (NSString *)infoPathForRootPath:(NSString *)path {
    return [path stringByAppendingPathComponent:@"Info.json"];
}

#pragma mark -
#pragma mark - Helpers
+ (NSString *)preferedMimeTypeForFileExtention:(NSString *)extention {
    if (extention.length == 0) {
        return @"application/octet-stream";
    }
#if TARGET_OS_IPHONE
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)extention, NULL);
    CFStringRef mimeType = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    if (!mimeType) {
        return @"application/octet-stream";
    } else {
        NSString *type = (__bridge NSString *)mimeType;
        CFRelease(mimeType);
        return type;
    }
#endif
    return @"application/octet-stream";
}

#pragma mark -
#pragma mark - Hash
- (BOOL)writeData:(NSData *)data toHash:(NSString *)hash info:(NSDictionary *)info error:(NSError **)error {
    MCTDataCacheObject *object = [self mct_objectForWriting:hash error:error];
    if (!object) {
        return NO;
    }
    if (![data writeToFile:object.filePath options:NSDataWritingAtomic error:error]) {
        return NO;
    }
    return [self mct_writeInfo:info forObject:object error:error];
}
- (BOOL)copyDataAtPath:(NSString *)copyPath toHash:(NSString *)hash info:(NSDictionary *)info error:(NSError **)error {
    MCTDataCacheObject *object = [self mct_objectForWriting:hash error:error];
    if (!object) {
        return NO;
    }
    if (![[NSFileManager defaultManager] copyItemAtPath:copyPath toPath:object.filePath error:error]) {
        return NO;
    }
    return [self mct_writeInfo:info forObject:object error:error];
}
- (MCTDataCacheObject *)mct_objectForWriting:(NSString *)hash error:(NSError **)error {
    MCTDataCacheObject *object = [self cachedObjectWithHash:hash error:error];
    if (!error) {
        return nil;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:object.filePath isDirectory:NULL]) {
        if (![self deleteHash:hash error:error]) {
            return nil;
        }
        if (![self createDirectoryForPath:object.rootPath error:error]) {
            return nil;
        }
    }
    return object;
}
- (BOOL)mct_writeInfo:(NSDictionary *)info forObject:(MCTDataCacheObject *)object error:(NSError **)error {
    NSJSONWritingOptions options = 0;
#if DEBUG
    options |= NSJSONWritingPrettyPrinted;
#endif
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:object.filePath error:error];
    if (!fileAttributes) {
        return NO;
    }
    uint64_t fileSize = [fileAttributes[NSFileSize] unsignedLongLongValue];
    info = [MCTDataCacheMetaData updateInfo:info fileSize:fileSize readDate:[NSDate date] path:object.rootPath hash:object.hash];
    NSData *JSON = [NSJSONSerialization dataWithJSONObject:info options:options error:error];
    if (!JSON) {
        return NO;
    }
    return [JSON writeToFile:object.fileInfoPath options:NSDataWritingAtomic error:error];
}

- (BOOL)deleteHash:(NSString *)hash error:(NSError **)error {
    NSString *path = [self directoryForCacheWithHash:hash error:error];
    if (!path) {
        return NO;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:NULL]) {
        return [[NSFileManager defaultManager] removeItemAtPath:path error:error];
    }
    return YES;
}

#pragma mark -
#pragma mark - Contents
- (NSSet *)infoFilePaths {
    NSString *currentPath = [[self class] rootCacheDirectoryPath];
    NSArray *rootPaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:currentPath error:nil];
    NSMutableSet *set = [NSMutableSet set];
    for (NSString *path in rootPaths) { @autoreleasepool {
        NSArray *hashPaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[currentPath stringByAppendingPathComponent:path] error:nil];
        for (NSString *hash in hashPaths) {
            NSString *fullPath = [[currentPath stringByAppendingPathComponent:path] stringByAppendingPathComponent:hash];
            NSString *info = [self infoPathForRootPath:fullPath];
            if (info) {
                [set addObject:info];
            }
        }
    }}
    return [set copy];
}

- (BOOL)flushCacheWithError:(NSError **)error {
    NSString *path = [[self class] mct_cacheDirectory];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return [[NSFileManager defaultManager] removeItemAtPath:[[self class] mct_cacheDirectory] error:error];
    }
    return YES;
}

@end
