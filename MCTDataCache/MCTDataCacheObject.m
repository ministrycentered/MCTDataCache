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
@synthesize info = _info;

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
- (NSDictionary *)info {
    if (!_info) {
        if (self.fileInfoPath && [[NSFileManager defaultManager] fileExistsAtPath:self.fileInfoPath]) {
            NSData *data = [NSData dataWithContentsOfFile:self.fileInfoPath];
            if (data) {
                _info = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            }
        }
    }
    return _info;
}

@end
