////////////////////////////////////////////////////////////////////
//                          _ooOoo_                               //
//                         o8888888o                              //
//                         88" . "88                              //
//                         (| ^_^ |)                              //
//                         O\  =  /O                              //
//                      ____/`---'\____                           //
//                    .'  \\|     |//  `.                         //
//                   /  \\|||  :  |||//  \                        //
//                  /  _||||| -:- |||||-  \                       //
//                  |   | \\\  -  /// |   |                       //
//                  | \_|  ''\---/''  |   |                       //
//                  \  .-\__  `-`  ___/-. /                       //
//                ___`. .'  /--.--\  `. . ___                     //
//              ."" '<  `.___\_<|>_/___.'  >'"".                  //
//            | | :  `- \`.;`\ _ /`;.`/ - ` : | |                 //
//            \  \ `-.   \_ __\ /__ _/   .-` /  /                 //
//      ========`-.____`-.___\_____/___.-`____.-'========         //
//                           `=---='                              //
//      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^        //
//               佛祖保佑      永无BUG     永不修改                   //
////////////////////////////////////////////////////////////////////
//
//  AFDownLoadHelper.h
//  DownLoad
//
//  Created by 卿伟 on 2018/4/17.
//  Copyright © 2018年 卿伟. All rights reserved.
//
#import "ViewController.h"
#import "AFNetworking.h"
#import <Foundation/Foundation.h>
#import "DownLoadModel.h"
@interface AFDownLoadHelper : NSObject
- (NSURLSessionDataTask *)downloadURL:(NSString *) downloadURL progress:(void (^)(DownLoadModel * downloadModel))progress success:(void (^)(NSString *filePath))success failure:(void(^)(NSError *error))faliure;
@end
