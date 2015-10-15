/*!
 * MCTDataCacheController.h
 *
 * Copyright (c) 2014 Ministry Centered Technology
 *
 * Created by Skylar Schipper on 3/7/14
 */

#ifndef MCTDataCache_MCTDataCacheController_h
#define MCTDataCache_MCTDataCacheController_h

@import Foundation;
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

- (void)cachedDataForKey:(NSString *)key dataLoader:(NSData *(^)(NSString *key, NSError **error))loader completion:(void(^)(NSURL *fileURL, NSDictionary *info, NSError *error))completion;

- (void)copyFileAtURLToCache:(NSURL *)fileURL fileName:(NSString *)fileName completion:(void(^)(NSURL *fileURL, NSDictionary *info, NSError *error))completion;
- (NSURL *)fileURLForKey:(NSString *)key error:(NSError **)error;
- (NSURL *)fileNameURLForKey:(NSString *)key error:(NSError **)error;
- (BOOL)fileExistsForKey:(NSString *)key;

- (void)writeData:(NSData *)data forURL:(NSURL *)URL fileName:(NSString *)fileName completion:(void(^)(NSURL *fileURL, NSDictionary *info, NSError *error))completion;
- (void)writeData:(NSData *)data forKey:(NSString *)key fileName:(NSString *)fileName completion:(void(^)(NSURL *fileURL, NSDictionary *info, NSError *error))completion;

- (BOOL)removeItemWithKey:(NSString *)key error:(NSError **)error;
- (BOOL)removeItemWithURL:(NSURL *)URL error:(NSError **)error;

#pragma mark -
#pragma mark - Info
- (uint64_t)cacheSizeInBytes;
- (void)getCacheSize:(void(^)(uint64_t size))completion;

- (BOOL)cacheIsOversized;

- (NSUInteger)count;

#pragma mark -
#pragma mark - Flush
- (BOOL)flush;
- (BOOL)flushWithError:(NSError **)error;

@end

#if TARGET_OS_IPHONE

@import UIKit;

@interface MCTDataCacheController (DataCacheControllerMobile)

- (void)cachedImageAtURL:(NSURL *)imageURL completion:(void(^)(UIImage *image, NSError *error))completion;
- (void)cachedImageAtURL:(NSURL *)imageURL name:(NSString *)name completion:(void (^)(UIImage *image, NSError *error))completion;

@end

#endif

OBJC_EXTERN NSString * const MCTDataCacheControllerErrorDomain;

#endif
