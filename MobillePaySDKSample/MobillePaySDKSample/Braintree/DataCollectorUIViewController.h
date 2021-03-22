//
//  DataCollectorUIViewController.h
//  MobillePaySDKSample
//
//  Created by fly.zhu on 2021/3/22.
//  Copyright © 2021 Yuanex, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTAPIClient.h"

NS_ASSUME_NONNULL_BEGIN

@interface DataCollectorUIViewController : UIViewController

@property (nonatomic, copy) NSString *deviceData;

- (void) collectDeviceData:(BTAPIClient*) apiClient;

@end

NS_ASSUME_NONNULL_END
