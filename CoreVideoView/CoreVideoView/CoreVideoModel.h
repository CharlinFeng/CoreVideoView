//
//  ViewController.h
//  CoreVideoView
//
//  Created by 冯成林 on 16/1/8.
//  Copyright © 2016年 冯成林. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface CoreVideoModel : NSObject <AVCaptureFileOutputRecordingDelegate>

@property (nonatomic, strong) AVCaptureMovieFileOutput *output;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *AVPlayerLayer;
@property (nonatomic, strong) NSString *videoPath;

- (void)setRecVideoAndVideoPreviewLayer:(UIView *)view;
- (void)beginRecordSaveToTheDocumentFilePath:(NSString *)filePath; //开始录制视频 并存到沙箱中
- (void)stopVideoRecorder;
-(void)prepare;
@end
