/*!
 * MCTDataCacheURLFormatter.m
 *
 * Copyright (c) 2014 Ministry Centered Technology
 *
 * Created by Skylar Schipper on 3/7/14
 */

#import "MCTDataCacheURLFormatter.h"
#import "MCTDataCacheHelpers.h"

@interface MCTDataCacheURLFormatter ()

@end

@implementation MCTDataCacheURLFormatter

+ (NSString *)fileHashForURL:(NSURL *)URL {
    return [self fileHashForURL:URL params:NULL];
}
+ (NSString *)fileHashForURL:(NSURL *)URL params:(NSDictionary **)params {
    return [self fileHashForURL:URL params:params fileName:NULL];
}
+ (NSString *)fileHashForURL:(NSURL *)URL params:(NSDictionary **)params fileName:(NSString **)fileName {
    NSString *URLString = [URL absoluteString];
    NSArray *components = [URLString componentsSeparatedByString:@"?"];
    if (params != NULL) {
        NSString *query = [components lastObject];
        NSMutableDictionary *_params = [NSMutableDictionary dictionary];
        for (NSString *keyVal in [query componentsSeparatedByString:@"&"]) {
            NSArray *info = [keyVal componentsSeparatedByString:@"="];
            NSString *key = [[info firstObject] stringByRemovingPercentEncoding];
            NSString *val = [[info lastObject] stringByRemovingPercentEncoding];
            if (key && val) {
                _params[key] = val;
            }
        }
        if (!_params[@"filename"] && _params[@"response-content-disposition"]) {
            NSString *_fileName = [self fileNameFromDisposition:_params[@"response-content-disposition"]];
            if (_fileName) {
                _params[@"filename"] = _fileName;
                if (fileName != NULL) {
                    *fileName = [_fileName copy];
                }
            }
        }
        if (!_params[@"filename"]) {
            NSString *_fileName = [[[URL path] pathComponents] lastObject];
            if (_fileName) {
                _params[@"filename"] = _fileName;
                if (fileName != NULL) {
                    *fileName = [_fileName copy];
                }
            }
        }
        *params = [_params copy];
    }
    return MCTDataCacheSHA1String([components firstObject]);
}
+ (NSString *)fileNameFromDisposition:(NSString *)disposition {
    static NSRegularExpression *fileNameParser;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *error = NULL;
        fileNameParser = [NSRegularExpression regularExpressionWithPattern:@"filename=\\\"(.+?)\"" options:0 error:&error];
        if (error) {
            NSLog(@"Regex Error (%@) %@",error,NSStringFromClass([self class]));
        }
    });
    NSTextCheckingResult *firstMatch = [fileNameParser firstMatchInString:disposition options:0 range:NSMakeRange(0, disposition.length)];
    NSString *name = [disposition substringWithRange:firstMatch.range];
    name = [name substringToIndex:name.length - 1];
    name = [name stringByReplacingOccurrencesOfString:@"filename=\"" withString:@""];
    return name;
}

+ (NSString *)fileHashForName:(NSString *)name {
    return MCTDataCacheSHA1String(name);
}

@end
