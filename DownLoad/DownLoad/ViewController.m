//
//  ViewController.m
//  DownLoad
//
//  Created by 卿伟 on 2018/4/17.
//  Copyright © 2018年 卿伟. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "AFDownLoadHelper.h"
#import <AVFoundation/AVFoundation.h>
///这个视频 很小
#define URL @"https://aweme.snssdk.com/aweme/v1/playwm/?video_id=2066bfe5c00c4263a8549f7dcca08cb8&line=0"
/// 手机拍摄视频
//#define URL @"http://pic.zuanlinghua.com/video/VID_20180507_111140.mp4"
///这个是视频 200 多兆的
//#define URL @"http://pic.zuanlinghua.com/%5BFZSD%5D%5BKiratto_Pri-chan%5D%5B001%5D%5BGB%5D%5B720P%5D%5Bx264_AAC%5D.mp4"

#define FILEPATH [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"download/temp"]
#define GCD_ONCE(Block) static dispatch_once_t onceToken; dispatch_once(&onceToken, Block);

@interface ViewController (){
    NSURLSessionDataTask *task;
    NSFileHandle *fileHandle;
    UILabel *showLabel;
    __block  NSInteger  fileCompleteSize ;
    __block  NSUInteger fileTotalSize ;
    AFDownLoadHelper *downLoadHelper;
    NSString *putStr;
    
    UIButton *button1;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    downLoadHelper = [[AFDownLoadHelper alloc] init];
    NSLog(@"%@",FILEPATH);
    fileCompleteSize = 0;
    fileTotalSize = 0;
    button1 = [[UIButton alloc ] init];
    button1.frame = CGRectMake(210, 40, 80, 100);
    [button1 setTitle:@"开始下载" forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(action_btn:) forControlEvents:UIControlEventTouchUpInside];
    button1.tag = 1;
    button1.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:button1];
    showLabel = [[UILabel alloc] init];
    showLabel.frame = CGRectMake(0, 200, self.view.frame.size.width, 40);
    showLabel.textAlignment = NSTextAlignmentCenter;
    showLabel.textColor = [UIColor redColor];
    [self.view addSubview:showLabel];
}

// 2018/4/17 视频转码  问题：当视频过大时  CPU 消耗的特别厉害 500% 真机直接转码失败 模拟器还能坚持。风扇 呼呼呼呼呼 转
/// 2018-5-7 测试了几次 如果是用手机拍摄的视频 转换效率还是很高的 150M（1分钟左右的视频） 大概 10秒左右能转化出来 可能和视频时长有关吧。
- (void)videoTranscoding:(NSString *)filePath{
    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
    //转换后的视频地址
    NSString *output = [NSHomeDirectory() stringByAppendingString:@"/Documents/IMG_0757.MOV"];
    NSURL *outputUrl = [NSURL fileURLWithPath:output];
    putStr = output;
    //创建AVURLAsset实例
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:fileUrl options:nil];
    //得到可以转换的压缩选项
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:asset];
    if([compatiblePresets containsObject:AVAssetExportPresetMediumQuality]){
    
        AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
        //设置转换后的地址
        exportSession.outputURL = outputUrl;
        //设置转换后的格式
        exportSession.outputFileType = AVFileTypeQuickTimeMovie;
        /// 转码进度
        /* Specifies the progress of the export on a scale from 0 to 1.0.  A value of 0 means the export has not yet begun, A value of 1.0 means the export is complete. This property is not key-value observable. */
        NSTimer *tempTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
            NSOperationQueue* mainQueue = [NSOperationQueue mainQueue];
            [mainQueue addOperationWithBlock:^{
                showLabel.text = [NSString stringWithFormat:@"转码进度 ：%.2f ",exportSession.progress];
            }];
        }];
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            [tempTimer invalidate];
            /// 转码完成后 删除原来的视频
             NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager removeItemAtPath:filePath error:nil];
            
            switch (exportSession.status) {
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"AVAssetExportSessionStatusCancelled");
                    break;
                case AVAssetExportSessionStatusUnknown:
                    NSLog(@"AVAssetExportSessionStatusUnknown");
                    break;
                case AVAssetExportSessionStatusWaiting:
                    NSLog(@"AVAssetExportSessionStatusWaiting");
                    break;
                case AVAssetExportSessionStatusExporting:
                    NSLog(@"AVAssetExportSessionStatusExporting");
                    break;
                case AVAssetExportSessionStatusCompleted:
                {
                    UIAlertController *alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"转换完成" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *confirm=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
                    [alert addAction:confirm];
                    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
                    /// 将视频保存到 相册
                    [self saveVideo:output];
                    showLabel.text = [NSString stringWithFormat:@"转码进度 1.0"];
                    break;
                }
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"AVAssetExportSessionStatusFailed");
                    break;
            }
        }];
    }
}
 /// 将视频保存到 相册

- (void)saveVideo:(NSString *)videoPath{
    
    if (videoPath) {
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(videoPath)) {
            //保存相册核心代码
            UISaveVideoAtPathToSavedPhotosAlbum(videoPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        }
    }
    
}
///保存视频到相册后的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    /// 保存后删除 转码视频
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:putStr error:nil];
    if (error) {
        NSLog(@"保存视频失败%@", error.localizedDescription);
    }
    else {
        NSLog(@"保存视频成功");
    }
    
}
- (void)action_btn:(UIButton *)sender{
    [self contiuneAction];
    if(sender.tag == 1){
         [task resume];
         [sender setTitle:@"暂停下载" forState:UIControlStateNormal];
          sender.tag = 2;
    }else{
         [task suspend];
         sender.tag = 1;
         [sender setTitle:@"继续下载" forState:UIControlStateNormal];
    }
}
/// 下载视频  可断点续传
- (void)contiuneAction{
    if(task){
        return;
    }
    task = [downLoadHelper downloadURL:URL progress:^(DownLoadModel *downloadModel) {
        NSOperationQueue* mainQueue = [NSOperationQueue mainQueue];
        [mainQueue addOperationWithBlock:^{
           showLabel.text = [NSString stringWithFormat:@"%.2f MB/ %.2f MB",downloadModel.currentUnitCount,downloadModel.totalUnitCount];
        }];
        
    } success:^(NSString *filePath) {
        NSLog(@"%@",filePath);
        NSOperationQueue* mainQueue = [NSOperationQueue mainQueue];
        [mainQueue addOperationWithBlock:^{
            [self videoTranscoding:filePath];
            [button1 setTitle:@"下载完成" forState:UIControlStateNormal];
            button1.enabled = NO;
        }];
    } failure:^(NSError *error) {
          NSLog(@"%@",error);
    }];
  
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
