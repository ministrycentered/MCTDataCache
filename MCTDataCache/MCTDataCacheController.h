/*!
 * MCTDataCacheController.h
 *
 * Copyright (c) 2014 Ministry Centered Technology
 *
 * Created by Skylar Schipper on 3/7/14
 */

#ifndef MCTDataCache_MCTDataCacheController_h
#define MCTDataCache_MCTDataCacheController_h

#import <Foundation/Foundation.h>
#import "MCTDataCacheData.h"

@class MCTDataCacheFileManager;

@protocol MCTDataCacheNetworkRequestHandlerProtocol;

/*!
 *
 */
@interface MCTDataCacheController : NSObject

/*!
 *  Shared instance class method for accessing the shared instance of MCTDataCacheController
 *
 *  \return Returns the shared instance of MCTDataCacheController
 */
+ (instancetype)sharedCache;

/*!
 *  Set the maximum size of the data cache.
 *  Default is 500MB
 */
@property (nonatomic) MCTDataCacheSize maxCacheSize;

@property (nonatomic, strong, readonly) MCTDataCacheFileManager *fileManager;

@property (nonatomic, strong, readonly) dispatch_queue_t cacheQueue;
@property (nonatomic, strong) Class<MCTDataCacheNetworkRequestHandlerProtocol> networkClass;

#pragma mark -
#pragma mark - Cache Methods
- (void)cachedFileAtURL:(NSURL *)fileURL completion:(void(^)(NSURL *fileURL, NSDictionary *info, NSError *error))completion;
- (void)cachedFileAtURL:(NSURL *)fileURL fileName:(NSString *)fileName completion:(void(^)(NSURL *fileURL, NSDictionary *info, NSError *error))completion;

#pragma mark -
#pragma mark - Info
- (uint64_t)cacheSizeInBytes;
- (void)getCacheSize:(void(^)(uint64_t size))completion;

- (BOOL)cacheIsOversized;

#pragma mark -
#pragma mark - Flush
- (BOOL)flush;
- (BOOL)flushWithError:(NSError **)error;

@end

#endif
