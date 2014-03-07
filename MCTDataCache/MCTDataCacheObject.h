/*!
 * MCTDataCacheObject.h
 *
 * Copyright (c) 2014 Ministry Centered Technology
 *
 * Created by Skylar Schipper on 3/7/14
 */

#ifndef MCTDataCacheObject_h
#define MCTDataCacheObject_h

#import <Foundation/Foundation.h>

@interface MCTDataCacheObject : NSObject

@property (nonatomic, strong, readonly) NSString *hash;
@property (nonatomic, strong, readonly) NSString *rootPath;
@property (nonatomic, strong, readonly) NSString *filePath;
@property (nonatomic, strong, readonly) NSString *fileInfoPath;

- (instancetype)initWithHash:(NSString *)hash rootPath:(NSString *)rootPath filePath:(NSString *)filePath fileInfoPath:(NSString *)fileInfoPath;

@end

#endif
