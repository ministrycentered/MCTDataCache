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
    dispatch_async(self.cacheQueue, ^{
        uint64_t size = [self cacheSizeInBytes];
        if (completion) {
            completion(size);
        }
    });
}

- (BOOL)cacheIsOversized {
    return (self.maxCacheSize <= [self cacheSizeInBytes]);
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
    dispatch_async(self.cacheQueue, ^{
        NSString *hash = [MCTDataCacheURLFormatter fileHashForURL:fileURL params:NULL fileName:NULL];
        NSError *error = nil;
        NSString *_fileName = [fileName copy];
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
    });
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


@end
