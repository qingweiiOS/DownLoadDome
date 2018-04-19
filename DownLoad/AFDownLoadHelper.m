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
//               佛祖保佑      永无BUG     永不修改                  //
////////////////////////////////////////////////////////////////////
//
//  AFDownLoadHelper.m
//  DownLoad
//
//  Created by 卿伟 on 2018/4/17.
//  Copyright © 2018年 卿伟. All rights reserved.
//
//#define FILEPATH [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"download/video"]
#define TEMPFILEPATH [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"download/temp"]
#import "AFDownLoadHelper.h"
@interface AFDownLoadHelper(){
    NSURLSessionDataTask *task;
    NSFileHandle *fileHandle;
    UILabel *showLabel;
    __block  NSInteger  fileCompleteSize ;
    __block  NSUInteger fileTotalSize ;
}
@end
@implementation AFDownLoadHelper
//获取已下载的文件大小
- (unsigned long long)fileSizeForPath:(NSString *)path {
    signed long long fileSize = 0;
    NSFileManager *fileManager = [NSFileManager new]; // default is not thread safe
    if ([fileManager fileExistsAtPath:path]) {
        NSError *error = nil;
        NSDictionary *fileDict = [fileManager attributesOfItemAtPath:path error:&error];
        if (!error && fileDict) {
            fileSize = [fileDict fileSize];
        }
    }
    
    return fileSize;
}

- (NSURLSessionDataTask *)downloadURL:(NSString *) downloadURL progress:(void (^)(DownLoadModel * downloadModel))progress success:(void (^)(NSString *filePath))success failure:(void(^)(NSError *error))faliure{
    
    NSString *fileName = [TEMPFILEPATH stringByAppendingPathComponent:@"234.MOV"];
    
    fileCompleteSize = [self fileSizeForPath:fileName];
    NSInteger fileCompleteSize2 = fileCompleteSize;
   __block DownLoadModel * model = [[DownLoadModel alloc] init];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"audio/mp3",@"text/plain",@"text/html／",@"video/mp4",@"VIDEO/MP4",nil];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:downloadURL]];
    NSString *range = [NSString stringWithFormat:@"bytes=%zd-", fileCompleteSize];
    [request setValue:range forHTTPHeaderField:@"Range"];
    task = [manager dataTaskWithRequest:request uploadProgress:NULL downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        ///总大小 = downloadProgress.totalUnitCount（当前会下载的大小）+fileCompleteSize2（上一次下载的大小）
//        GCD_ONCE(^{
            fileTotalSize = downloadProgress.totalUnitCount+fileCompleteSize2;
//        })
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSLog(@"2->%ld ======", fileTotalSize);
         [fileHandle closeFile];///关闭文件
        if(error){
            NSLog(@"%@",error);
            faliure(error);
        }else{
        NSLog(@"下载成功 路径:%@",fileName);
        success(fileName);
        }
       
    }];
    /// 接受到反馈
    [manager setDataTaskDidReceiveResponseBlock:^NSURLSessionResponseDisposition(NSURLSession * _Nonnull session, NSURLSessionDataTask * _Nonnull dataTask, NSURLResponse * _Nonnull response) {
        
        NSFileManager *fma = [NSFileManager defaultManager];
        ///创建文件夹
        BOOL b = [fma createDirectoryAtPath:TEMPFILEPATH withIntermediateDirectories:YES attributes:nil error:NULL];
        if (b) {
            NSLog(@"创建成功");
        }else{
            NSLog(@"创建失败【已存在 文件夹】");
        }
        // 判断指定路径是否存在
        if (![fma fileExistsAtPath:fileName]) {
            //如果不存在就创建
            b =  [fma createFileAtPath:fileName contents:nil attributes:nil];
            if (b) {
                NSLog(@"创建路径成功");
            }else{
                NSLog(@"创建路径失败");
            }
        }
        
        ///读取指定路径文件
        fileHandle = [NSFileHandle fileHandleForWritingAtPath:fileName];
        ///允许处理服务器的响应，才会继续加载服务器的数据
        return NSURLSessionResponseAllow;
    }];
    ///接受数据到数据后的回调
    [manager setDataTaskDidReceiveDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDataTask * _Nonnull dataTask, NSData * _Nonnull data) {
        //将当前文件的操作位置设定为文件的末尾处 返回文件大小 【字节】
        [fileHandle seekToEndOfFile];
        //写入数据到文件末尾
        [fileHandle writeData:data];
        fileCompleteSize += data.length;
        model.progess = (float)(fileCompleteSize/1024/1024)/(fileTotalSize/1024/1024);
        model.currentUnitCount = (float)(fileCompleteSize/1024/1024);
        model.totalUnitCount = (float)(fileTotalSize/1024/1024);
        progress(model);
    }];
    
    return task;
}


@end
