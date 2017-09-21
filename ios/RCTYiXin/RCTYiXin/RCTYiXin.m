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
    callback(@[[NSNull null], [YXApi getTokenByUseDelegate:self OauthReq:(SendOAuthToYXReq *)req redirectURL : (NSString *)redirectURL]]);
}

RCT_EXPORT_METHOD(getYXOauthToken:(RCTResponseSenderBlock)callback)
{
    callback(@[([YXApi getYXOauthToken])]);
}

RCT_EXPORT_METHOD(sendReq:(NSString *)openid
                  :(RCTResponseSenderBlock)callback)
{
    YXBaseReq* req = [[YXBaseReq alloc] init];
    req.openID = openid;
    callback(@[[YXApi sendReq:req] ? [NSNull null] : INVOKE_FAILED]);
}

RCT_EXPORT_METHOD(sendResp:(RCTResponseSenderBlock)callback)
{
    YXBaseReq* resp = [[YXBaseReq alloc] init];
    resp.errCode = WXSuccess;
    callback(@[[YXApi sendResp:resp] ? [NSNull null] : INVOKE_FAILED]);
}

#pragma mark - wx callback

-(void) onReceiveRequest:(YXBaseReq*)req
{
    // TODO(Yorkie)
}

-(void) onReceiveResponse:(YXBaseReq*)resp
{
    if([resp isKindOfClass:[SendMessageToYXResp class]])
    {
        SendMessageToYXResp *r = (SendMessageToYXResp *)resp;
        
        NSMutableDictionary *body = @{@"errCode":@(r.errCode)}.mutableCopy;
        body[@"errStr"] = r.errStr;
        body[@"lang"] = r.lang;
        body[@"country"] =r.country;
        body[@"type"] = @"SendMessageToWX.Resp";
        [self.bridge.eventDispatcher sendDeviceEventWithName:RCTYXEventName body:body];
    } else if ([resp isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp *r = (SendAuthResp *)resp;
        NSMutableDictionary *body = @{@"errCode":@(r.errCode)}.mutableCopy;
        body[@"errStr"] = r.errStr;
        body[@"state"] = r.state;
        body[@"lang"] = r.lang;
        body[@"country"] =r.country;
        body[@"type"] = @"SendAuth.Resp";
        
        if (resp.errCode == WXSuccess)
        {
            [body addEntriesFromDictionary:@{@"appid":self.appId, @"code" :r.code}];
            [self.bridge.eventDispatcher sendDeviceEventWithName:RCTYXEventName body:body];
        }
        else {
            [self.bridge.eventDispatcher sendDeviceEventWithName:RCTYXEventName body:body];
        }
    } else if ([resp isKindOfClass:[PayResp class]]) {
        PayResp *r = (PayResp *)resp;
        NSMutableDictionary *body = @{@"errCode":@(r.errCode)}.mutableCopy;
        body[@"errStr"] = r.errStr;
        body[@"type"] = @(r.type);
        body[@"returnKey"] =r.returnKey;
        body[@"type"] = @"PayReq.Resp";
        [self.bridge.eventDispatcher sendDeviceEventWithName:RCTYXEventName body:body];
    }
}

@end

