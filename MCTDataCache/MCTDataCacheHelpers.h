//
//  MCTDataCacheHelpers.h
//  MCTDataCache
//
//  Created by Skylar Schipper on 3/7/14.
//  Copyright (c) 2014 Ministry Centered Technology. All rights reserved.
//

#ifndef MCTDataCache_MCTDataCacheHelpers_h
#define MCTDataCache_MCTDataCacheHelpers_h

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCrypto.h>

NS_INLINE NSString *MCTDataCacheSHA1Data(NSData *data) {
    if (!data) {
        return nil;
    }
    CC_LONG dataLength = (CC_LONG)data.length;
    const void *cData = data.bytes;
    unsigned char *buffer = malloc(CC_SHA1_DIGEST_LENGTH);
    CC_SHA1(cData, dataLength, buffer);
    NSMutableString *string = [NSMutableString stringWithCapacity:(CC_SHA1_DIGEST_LENGTH * 2)];
    for (NSUInteger idx = 0; idx < CC_SHA1_DIGEST_LENGTH; idx++) {
        [string appendFormat:@"%02X",buffer[idx]];
    }
    free(buffer);
    return [string copy];
}
NS_INLINE NSString *MCTDataCacheSHA1String(NSString *string) {
    return MCTDataCacheSHA1Data([string dataUsingEncoding:NSUTF8StringEncoding]);
}

NS_INLINE NSString *MCTDataCacheVersionPathString(void) {
    return @"1_0";
}

#endif
