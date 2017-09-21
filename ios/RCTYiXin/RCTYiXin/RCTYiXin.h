//
//  RCTYiXin.h
//  RCTYiXin
//
//  Created by china-mobile2008 on 2017/9/21.
//  Copyright © 2017年 china-mobile2008. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <React/RCTBridgeModule.h>
#import "YXApi.h"

// define share type constants
#define RCTYXShareTypeNews @"news"
#define RCTYXShareTypeThumbImageUrl @"thumbImage"
#define RCTYXShareTypeImageUrl @"imageUrl"
#define RCTYXShareTypeImageFile @"imageFile"
#define RCTYXShareTypeImageResource @"imageResource"
#define RCTYXShareTypeText @"text"
#define RCTYXShareTypeVideo @"video"
#define RCTYXShareTypeAudio @"audio"
#define RCTYXShareTypeFile @"file"

#define RCTYXShareType @"type"
#define RCTYXShareTitle @"title"
#define RCTYXShareDescription @"description"
#define RCTYXShareWebpageUrl @"webpageUrl"
#define RCTYXShareImageUrl @"imageUrl"

#define RCTYXEventName @"YiXin_Resp"

@interface RCTYiXin : NSObject <RCTBridgeModule, YXApiDelegate>

@property NSString* appId;

@end
