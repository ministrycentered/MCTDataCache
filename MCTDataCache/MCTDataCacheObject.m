/*!
 * MCTDataCacheObject.m
 *
 * Copyright (c) 2014 Ministry Centered Technology
 *
 * Created by Skylar Schipper on 3/7/14
 */

#import "MCTDataCacheObject.h"

@interface MCTDataCacheObject ()

@end

@implementation MCTDataCacheObject

- (instancetype)initWithHash:(NSString *)hash rootPath:(NSString *)rootPath filePath:(NSString *)filePath fileInfoPath:(NSString *)fileInfoPath {
    self = [super init];
    if (self) {
        _hash = hash;
        _filePath = filePath;
        _fileInfoPath = fileInfoPath;
        _rootPath = rootPath;
    }
    return self;
}

@end
