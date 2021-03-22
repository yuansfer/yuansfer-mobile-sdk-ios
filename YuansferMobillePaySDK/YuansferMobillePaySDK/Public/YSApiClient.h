//
//  YSApiClient.h
//
//  Created by fly.zhu on 2021/3/15.
//  Copyright © 2021 Yuanex, Inc. All rights reserved.
//

#import "BTAPIClient.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSApiClient : NSObject

@property (nonatomic, strong) BTAPIClient *apiClient;

+ (instancetype)sharedInstance;

- (NSString *)version;

- (void) initBraintreeClient:(NSString*) authorization;

@end

NS_ASSUME_NONNULL_END
