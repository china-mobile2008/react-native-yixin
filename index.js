'use strict';

import { DeviceEventEmitter, NativeModules, Platform } from 'react-native';
import { EventEmitter } from 'events';

let isAppRegistered = false;
const { YiXin } = NativeModules;

function wrapRegisterApp(nativeFunc) {
  if (!nativeFunc) {
    return undefined;
  }
  return (...args) => {
    if (isAppRegistered) {
      return Promise.resolve(true);
    }
    isAppRegistered = true;
    return new Promise((resolve, reject) => {
      nativeFunc.apply(null, [
        ...args,
        (error, result) => {
          if (!error) {
            return resolve(result);
          }
          if (typeof error === 'string') {
            return reject(new Error(error));
          }
          reject(error);
        },
      ]);
    });
  };
}

function wrapApi(nativeFunc) {
  if (!nativeFunc) {
    return undefined;
  }
  return (...args) => {
    if (!isAppRegistered) {
      return Promise.reject(new Error('registerApp required.'));
    }
    return new Promise((resolve, reject) => {
      nativeFunc.apply(null, [
        ...args,
        (error, result) => {
          if (!error) {
            return resolve(result);
          }
          if (typeof error === 'string') {
            return reject(new Error(error));
          }
          reject(error);
        },
      ]);
    });
  };
}

/*! @brief 注册第三方App到易信客户端。
 *
 * 启动三方App程序时调用，第一次调用后会在易信客户端的可用应用列表中出现。
 * @param appID 易信开放平台注册的开发者ID
 * @return 成功返回YES，失败返回NO。
 */
export const registerApp = (YiXin.registerApp);

/*! @brief 注册第三方App到易信客户端。
 *
 * 启动三方App程序时调用，第一次调用后会在易信客户端的可用应用列表中出现。
 * @param appID 易信开放平台注册的开发者ID
 * @param appSecret 易信开放平台注册的appSecret，如果不用登录认证功能可以传入空值
 * @return 成功返回YES，失败返回NO。
 */
 export const registerAppID = (YiXin.registerAppID);

/*! @brief 检查易信客户端是否已安装
 *
 * @return 易信已安装返回YES，未安装返回NO。
 */
 export const isYXAppInstalled = (YiXin.isYXAppInstalled);

/*! @brief 判断当前易信客户端的版本是否支持易信分享
 *
 * @return 支持返回YES，不支持返回NO。
 */
 export const isYXAppSupportApi = (YiXin.isYXAppSupportApi);

/*! @brief 判断当前易信客户端的版本是否支持OAuth授权
 *
 * @return 支持返回YES，不支持返回NO。
 */
 export const isYXAppSupportOAuth = (YiXin.isYXAppSupportOAuth);

/*! @brief 判断当前易信客户端的版本是否支持收藏到易信功能
 *
 * @return 支持返回YES，不支持返回NO。
 */
 export const isYXAppSupportFav = (YiXin.isYXAppSupportFav);

/*! @brief 打开易信客户端
 *
 * @return 成功返回YES，失败返回NO。
 */
 export const openYXApp = (YiXin.openYXApp);

/*! @brief 授权认证流程（登录易信）
 *
 * 安装易信时使用易信app完成流程；反之使用webview完成
 * 函数调用后，会弹出webview界面完成易信登录进行授权认证流程。
 * @param resp OAuth请求消息的对象，调用函数后，请自己释放。
 * @param redirectURL 你得应用在易信开放平台注册时提供的OAuth认证完成之后的回调url，仅供webview使用，请务必保证参数与你在open平台（http://open.yixin.im）或 游戏平台http://game.yixin.im 提交APP/游戏时注册的redirectURL一致，否则无法完成获取授权流程
 * @param delegate  YXApiDelegate对象，用来接收易信客户端触发的消息。授权成功数据将通过delegate的  onReceiveResponse方法进行通知
 * @return 请求是否发出
 */
 export const getTokenByUseDelegate = (YiXin.getTokenByUseDelegate);

/*! @brief 获取授权认证token
 *
 * 如果已授权则直接返回当前持有的token，否则返回nil
 * 此时请调 getTokenByUseDelegate: (id<YXApiDelegate>)delegate OauthReq:(SendOAuthToYXReq *)req redirectURL : (NSString *)redirectURL
 * 完成授权流程
 */
 export const getYXOauthToken = (YiXin.getYXOauthToken);
