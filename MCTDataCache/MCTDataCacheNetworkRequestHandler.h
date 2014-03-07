/*!
 * MCTDataCacheNetworkRequestHandler.h
 *
 * Copyright (c) 2014 Ministry Centered Technology
 *
 * Created by Skylar Schipper on 3/7/14
 */

#ifndef MCTDataCacheNetworkRequestHandler_h
#define MCTDataCacheNetworkRequestHandler_h

#import <Foundation/Foundation.h>

@protocol MCTDataCacheNetworkRequestHandlerProtocol <NSObject>

@required
+ (void)loadItemAtURL:(NSURL *)URL completion:(void(^)(NSURL *location, NSURLResponse *response, NSError *error))completion;

@end

@interface MCTDataCacheNetworkRequestHandler : NSObject <MCTDataCacheNetworkRequestHandlerProtocol>

@end

#endif
