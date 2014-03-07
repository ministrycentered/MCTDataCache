/*!
 * MCTDataCacheURLFormatter.h
 *
 * Copyright (c) 2014 Ministry Centered Technology
 *
 * Created by Skylar Schipper on 3/7/14
 */

#ifndef MCTDataCacheURLFormatter_h
#define MCTDataCacheURLFormatter_h

#import <Foundation/Foundation.h>

@interface MCTDataCacheURLFormatter : NSObject

/*!
 *  Parses a URL and returns the hash of the base URL
 *
 *  \param URL The URL to hash
 *
 *  \return The hashed URL
 */
+ (NSString *)fileHashForURL:(NSURL *)URL;
/*!
 *  Parses a URL and returns the hash of the base URL
 *
 *  \param URL    The URL to hash
 *  \param params The parameters found with the URL
 *
 *  \return The hashed URL
 */
+ (NSString *)fileHashForURL:(NSURL *)URL params:(NSDictionary **)params;
+ (NSString *)fileHashForURL:(NSURL *)URL params:(NSDictionary **)params fileName:(NSString **)fileName;

+ (NSString *)fileHashForName:(NSString *)name;

@end

#endif
