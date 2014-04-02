/*!
 * MCTDataCacheController.m
 *
 * Copyright (c) 2014 Ministry Centered Technology
 *
 * Created by Skylar Schipper on 3/7/14
 */


#import "MCTDataCacheController.h"
#import "MCTDataCacheHelpers.h"

#import "MCTDataCacheFileManager.h"
#import "MCTDataCacheMetaData.h"
#import "MCTDataCacheURLFormatter.h"
#import "MCTDataCacheNetworkRequestHandler.h"

id static _sharedMCTDataCacheController = nil;

@interface MCTDataCacheController ()

@end

@implementation MCTDataCacheController
@synthesize fileManager = _fileManager;
@synthesize cacheQueue = _cacheQueue;

#pragma mark -
#pragma mark - Initialization
- (id)init {
	self = [super init];
	if (self) {
        _maxCacheSize = MCTDataCacheSize_500MB;
        _networkClass = [MCTDataCacheNetworkRequestHandler class];
        [[NSFileManager defaultManager] removeItemAtPath:[MCTDataCacheFileManager tmpFilePath] error:nil];
	}
	return self;
}

#pragma mark -
#pragma mark - Singleton
+ (instancetype)sharedCache {
	@synchronized (self) {
        if (!_sharedMCTDataCacheController) {
            _sharedMCTDataCacheController = [[[self class] alloc] init];
        }
        return _sharedMCTDataCacheController;
    }
}

- (MCTDataCacheFileManager *)fileManager {
    @synchronized (self) {
        if (!_fileManager) {
            _fileManager = [[MCTDataCacheFileManager alloc] init];
        }
        return _fileManager;
    }
}
- (dispatch_queue_t)cacheQueue {
    if (!_cacheQueue) {
        _cacheQueue = dispatch_queue_create("com.ministrycentered.DataCacheQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    return _cacheQueue;
}

#pragma mark -
#pragma mark - Info
- (uint64_t)cacheSizeInBytes {
    return [[[MCTDataCacheMetaData infoForPaths:[self.fileManager infoFilePaths]] valueForKeyPath:[NSString stringWithFormat:@"@sum.%@",kMCTDataCacheSize]] unsignedLongLongValue];
}
- (void)getCacheSize:(void(^)(uint64_t size))completion {
    dispatch_async(self.cacheQueue, ^{ @autoreleasepool {
        uint64_t size = [self cacheSizeInBytes];
        if (completion) {
            completion(size);
        }
    }});
}

- (BOOL)cacheIsOversized {
    return (self.maxCacheSize <= [self cacheSizeInBytes]);
}

- (NSUInteger)count {
    return [[self.fileManager infoFilePaths] count];
}

#pragma mark -
#pragma mark - Flush
- (BOOL)flush {
    return [self flushWithError:NULL];
}
- (BOOL)flushWithError:(NSError **)error {
    return [self.fileManager flushCacheWithError:error];
}

#pragma mark -
#pragma mark - Cache Methods
- (void)cachedFileAtURL:(NSURL *)fileURL completion:(void(^)(NSURL *fileURL, NSDictionary *info, NSError *error))completion {
    NSDictionary *params = nil;
    NSString *name = nil;
    NSString *hash = [MCTDataCacheURLFormatter fileHashForURL:fileURL params:&params fileName:&name];
#pragma unused(hash)
    [self cachedFileAtURL:fileURL fileName:name completion:completion];
}
- (void)cachedFileAtURL:(NSURL *)fileURL fileName:(NSString *)fileName completion:(void(^)(NSURL *fileURL, NSDictionary *info, NSError *error))completion {
    if (!fileURL) {
        if (completion) {
            completion(nil, nil, [NSError errorWithDomain:MCTDataCacheControllerErrorDomain code:100 userInfo:nil]);
        }
        return;
    }
    dispatch_async(self.cacheQueue, ^{ @autoreleasepool {
        NSString *hash = [MCTDataCacheURLFormatter fileHashForURL:fileURL params:NULL fileName:NULL];
        NSError *error = nil;
        NSString *_fileName = [fileName copy];
        if (!_fileName) {
            _fileName = [[fileURL path] lastPathComponent];
        }
        if ([[_fileName pathExtension] length] == 0 && [[fileURL pathExtension] length] > 0) {
            _fileName = [_fileName stringByAppendingPathExtension:[fileURL pathExtension]];
        }
        if ([self.fileManager cacheExitsForHash:hash error:&error]) {
            if (error) {
                if (completion) {
                    completion(nil, nil, error);
                }
                return;
            }
            [self readCachedFileWithHash:hash completion:completion];
            return;
        }
        if (error) {
            if (completion) {
                completion(nil, nil, error);
            }
            return;
        }
#if DEBUG
        printf("MCTDataCache: {LOAD} %s\n",[[fileURL absoluteString] cStringUsingEncoding:NSUTF8StringEncoding]);
#endif
        [self.networkClass loadItemAtURL:fileURL completion:^(NSURL *location, NSURLResponse *response, NSError *error) {
            if (location && !error) {
                NSDictionary *info = [MCTDataCacheMetaData defaultMetaDataForFile:_fileName];
                NSError *copyError = nil;
                if (![self.fileManager copyDataAtPath:[location path] toHash:hash info:info error:&copyError]) {
                    if (completion) {
                        completion(nil, nil, copyError);
                    }
                    return;
                }
                [self readCachedFileWithHash:hash completion:completion];
                return;
            }
        }];
    }});
}
- (void)cachedDataForKey:(NSString *)key dataLoader:(NSData *(^)(NSString *key, NSError **error))loader completion:(void(^)(NSURL *fileURL, NSDictionary *info, NSError *error))completion {
    dispatch_async(self.cacheQueue, ^{ @autoreleasepool {
        NSString *hash = [MCTDataCacheURLFormatter fileHashForName:key];
        NSError *findError = nil;
        if ([self.fileManager cacheExitsForHash:hash error:&findError]) {
            if (findError) {
                if (completion) {
                    completion(nil, nil, findError);
                }
            }
            [self readCachedFileWithHash:hash completion:completion];
            return;
        }
        NSError *loadError = nil;
        NSData *data = loader(key, &loadError);
        if (data) {
            NSString *filename = @"file.dat";
            NSDictionary *info = [MCTDataCacheMetaData defaultMetaDataForFile:filename];
            NSError *writeError = nil;
            if (![self.fileManager writeData:data toHash:hash info:info error:&writeError]) {
                if (completion) {
                    completion(nil, nil, writeError);
                }
                return;
            }
            [self readCachedFileWithHash:hash completion:completion];
        } else {
            if (completion) {
                completion(nil, nil, loadError);
            }
        }
    }});
}

- (void)readCachedFileWithHash:(NSString *)hash completion:(void(^)(NSURL *fileURL, NSDictionary *info, NSError *error))completion {
    NSError *error = nil;
    MCTDataCacheObject *object = [self.fileManager cachedObjectWithHash:hash error:&error];
    NSURL *url = [NSURL fileURLWithPath:object.filePath];
    NSDictionary *info = [MCTDataCacheMetaData infoForPath:object.fileInfoPath error:&error];
    if (completion) {
        completion(url, info, error);
    }
}

- (BOOL)fileExistsForKey:(NSString *)key {
    NSString *fileKey = [MCTDataCacheURLFormatter fileHashForName:key];
    return [self.fileManager cacheExitsForHash:fileKey error:nil];
}
- (void)copyFileAtURLToCache:(NSURL *)fileURL fileName:(NSString *)fileName completion:(void(^)(NSURL *fileURL, NSDictionary *info, NSError *error))completion {
    if (![[NSFileManager defaultManager] fileExistsAtPath:[fileURL path] isDirectory:NULL]) {
        if (completion) {
            completion(nil, nil, [NSError errorWithDomain:MCTDataCacheControllerErrorDomain code:100 userInfo:nil]);
        }
        return;
    }
    
    NSString *hash = [MCTDataCacheURLFormatter fileHashForName:fileName];
    NSDictionary *info = [MCTDataCacheMetaData defaultMetaDataForFile:fileName];
    NSError *error = nil;
    if (![self.fileManager copyDataAtPath:[fileURL path] toHash:hash info:info error:&error]) {
        if (completion) {
            completion(nil, nil, error);
        }
        return;
    }
    [self readCachedFileWithHash:hash completion:completion];
}
- (NSURL *)fileURLForKey:(NSString *)key error:(NSError **)error {
    MCTDataCacheObject *object = [self.fileManager cachedObjectWithHash:[MCTDataCacheURLFormatter fileHashForName:key] error:error];
    if (!object) {
        return nil;
    }
    return [NSURL fileURLWithPath:object.filePath];
}

@end

#if TARGET_OS_IPHONE

@implementation MCTDataCacheController (DataCacheControllerMobile)

- (void)cachedImageAtURL:(NSURL *)imageURL completion:(void(^)(UIImage *image, NSError *error))completion {
    [self cachedFileAtURL:imageURL completion:^(NSURL *fileURL, NSDictionary *info, NSError *error) {
        if (error) {
            if (completion) {
                completion(nil, error);
            }
            return;
        }
        UIImage *image = nil;
        if (fileURL) {
            image = [UIImage imageWithContentsOfFile:[fileURL path]];
        }
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(image, nil);
            });
        }
    }];
}
- (void)cachedImageAtURL:(NSURL *)imageURL name:(NSString *)name completion:(void (^)(UIImage *image, NSError *error))completion {
    [self cachedFileAtURL:imageURL fileName:name completion:^(NSURL *fileURL, NSDictionary *info, NSError *error) {
        if (error) {
            if (completion) {
                completion(nil, error);
            }
            return;
        }
        UIImage *image = nil;
        if (fileURL) {
            image = [UIImage imageWithContentsOfFile:[fileURL path]];
        }
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(image, nil);
            });
        }
    }];
}

@end

#endif
NSString * const MCTDataCacheControllerErrorDomain = @"MCTDataCacheControllerErrorDomain";
