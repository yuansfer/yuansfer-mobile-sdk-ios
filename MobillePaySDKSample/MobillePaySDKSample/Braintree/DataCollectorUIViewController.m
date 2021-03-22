//
//  DataCollectorUIViewController.m
//  MobillePaySDKSample
//
//  Created by fly.zhu on 2021/3/22.
//  Copyright © 2021 Yuanex, Inc. All rights reserved.
//

#import "DataCollectorUIViewController.h"
#import "BTDataCollector.h"

@interface DataCollectorUIViewController ()

@end

@implementation DataCollectorUIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void) collectDeviceData:(BTAPIClient*) apiClient {
    BTDataCollector *dataCollector = [[BTDataCollector alloc] initWithAPIClient:apiClient];
    [dataCollector collectDeviceData:^(NSString * _Nonnull deviceData) {
      // Send deviceData to your server
        NSLog(@"DataCollectUIViewController deviceData=%@", deviceData);
        self.deviceData = deviceData;
    }];
}

@end
