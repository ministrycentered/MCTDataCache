/*!
 * MCTDataCacheNetworkRequestHandler.m
 *
 * Copyright (c) 2014 Ministry Centered Technology
 *
 * Created by Skylar Schipper on 3/7/14
 */

#import "MCTDataCacheNetworkRequestHandler.h"

@interface MCTDataCacheNetworkRequestHandler ()

@end

@implementation MCTDataCacheNetworkRequestHandler

+ (void)loadItemAtURL:(NSURL *)URL completion:(void(^)(NSURL *location, NSURLResponse *response, NSError *error))completion {
    [[[NSURLSession sharedSession] downloadTaskWithURL:URL completionHandler:completion] resume];
}

@end
