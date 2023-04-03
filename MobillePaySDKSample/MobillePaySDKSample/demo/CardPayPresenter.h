//
//  CardPayPresenter.h
//  MobillePaySDKSample
//
//  Created by fly.zhu on 2022/11/21.
//  Copyright © 2022 Yuanex, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasePayPresenter.h"

NS_ASSUME_NONNULL_BEGIN

@interface CardPayPresenter : BasePayPresenter

+ (instancetype)sharedPresenter;

- (void) reqCardPayWithJsonStr:(NSString *) jsonStr token:(NSString*) token completion:(void (^)(NSError * error))completionHandler;

@end

NS_ASSUME_NONNULL_END
