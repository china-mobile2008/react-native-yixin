//
//  RCTYiXin.m
//  RCTYiXin
//
//  Created by china-mobile2008 on 2017/9/21.
//  Copyright © 2017年 china-mobile2008. All rights reserved.
//

#import "RCTYiXin.h"
#import "YXApiObject.h"
#import <React/RCTEventDispatcher.h>
#import <React/RCTBridge.h>
#import <React/RCTLog.h>
#import <React/RCTImageLoader.h>

// Define error messages
#define NOT_REGISTERED (@"registerApp required.")
#define INVOKE_FAILED (@"YiXin API invoke returns false.")

@implementation RCTYiXin

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE()

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOpenURL:) name:@"RCTOpenURLNotification" object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)handleOpenURL:(NSNotification *)aNotification
{
    NSString * aURLString =  [aNotification userInfo][@"url"];
    NSURL * aURL = [NSURL URLWithString:aURLString];
    
    if ([YXApi handleOpenURL:aURL delegate:self])
    {
        return YES;
    } else {
        return NO;
    }
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_METHOD(registerApp:(NSString *)appid
                  :(RCTResponseSenderBlock)callback)
{
    self.appId = appid;
    callback(@[[YXApi registerApp:appid] ? [NSNull null] : INVOKE_FAILED]);
}

RCT_EXPORT_METHOD(registerAppID:(NSString *)appid
                  :(NSString *)appSecret
                  :(RCTResponseSenderBlock)callback)
{
    callback(@[[YXApi registerAppID:appid appSecret:appSecret] ? [NSNull null] : INVOKE_FAILED]);
}

RCT_EXPORT_METHOD(isYXAppInstalled:(RCTResponseSenderBlock)callback)
{
    callback(@[[NSNull null], @([YXApi isYXAppInstalled])]);
}

RCT_EXPORT_METHOD(isYXAppSupportApi:(RCTResponseSenderBlock)callback)
{
    callback(@[[NSNull null], @([YXApi isYXAppSupportApi])]);
}

RCT_EXPORT_METHOD(isYXAppSupportOAuth:(RCTResponseSenderBlock)callback)
{
    callback(@[[NSNull null], @([YXApi isYXAppSupportOAuth])]);
}

RCT_EXPORT_METHOD(isYXAppSupportFav:(RCTResponseSenderBlock)callback)
{
    callback(@[[NSNull null], @([YXApi isYXAppSupportFav])]);
}

RCT_EXPORT_METHOD(openYXApp:(RCTResponseSenderBlock)callback)
{
    callback(@[([YXApi openYXApp] ? [NSNull null] : INVOKE_FAILED)]);
}

RCT_EXPORT_METHOD(getTokenByUseDelegate
                  :(SendOAuthToYXReq *)req
                  :(NSString *)redirectURL
                  :(RCTResponseSenderBlock)callback)
{
    callback(@[[NSNull null], [YXApi getTokenByUseDelegate:self OauthReq:req redirectURL:redirectURL]]);
}

RCT_EXPORT_METHOD(getYXOauthToken:(RCTResponseSenderBlock)callback)
{
    callback(@[([YXApi getYXOauthToken])]);
}

RCT_EXPORT_METHOD(sendReq:(NSInteger)curScene
                  :(RCTResponseSenderBlock)callback)
{
    
    SendMessageToYXReq *req = [[SendMessageToYXReq alloc] init];
    req.bText = YES;
    req.text = @"http://img5.cache.netease.com/photo/ 童鞋，我想跟你说个事呀！童鞋，童鞋，我想跟你说个事呀！";
    req.scene = curScene;
    callback(@[[YXApi sendReq:req] ? [NSNull null] : INVOKE_FAILED]);
    [req release];
}

//RCT_EXPORT_METHOD(sendResp:(RCTResponseSenderBlock)callback)
//{
//    YXBaseReq* resp = [[YXBaseReq alloc] init];
//    resp.errCode = WXSuccess;
//    callback(@[[YXApi sendResp:resp] ? [NSNull null] : INVOKE_FAILED]);
//}

#pragma mark - wx callback

-(void) onReceiveRequest:(YXBaseReq*)req
{
    // TODO(Yorkie)
}

-(void) onReceiveResponse:(YXBaseReq*)resp
{
    if([resp isKindOfClass:[SendMessageToYXResp class]])
    {
        SendMessageToYXResp *sendResp = (SendMessageToYXResp *)resp;
        
        NSMutableDictionary *body = @{@"errCode":@(sendResp.code)}.mutableCopy;
        body[@"code"] = sendResp.code;
        body[@"errDescription"] = sendResp.errDescription;
        [self.bridge.eventDispatcher sendDeviceEventWithName:RCTYXEventName body:body];
    }
}

@end

