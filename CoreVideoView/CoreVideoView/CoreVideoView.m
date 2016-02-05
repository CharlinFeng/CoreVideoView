//
//  ViewController.h
//  CoreVideoView
//
//  Created by 冯成林 on 16/1/8.
//  Copyright © 2016年 冯成林. All rights reserved.
//

#import "CoreVideoView.h"
#import <AVFoundation/AVFoundation.h>
#import "NSString+CoreVideoFile.h"

#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width

@interface CoreVideoView ()

@property (nonatomic,copy) NSString *CoreVideoCacheFolderPath;

@property (nonatomic,copy) void(^SaveAblumResBlock)(NSError *error);

@property (nonatomic,assign) BOOL isRecord;

@property (nonatomic,assign) NSTimeInterval beginTime;


@end

@implementation CoreVideoView


-(instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if(self){
        
        //视图准备
        [self viewPrepare];
    }
    
    return self;
}


-(id)initWithCoder:(NSCoder *)aDecoder{
    
    self=[super initWithCoder:aDecoder];
    
    if(self){
        
        //视图准备
        [self viewPrepare];
    }
    
    return self;
}



/*
 *  视图准备
 */
-(void)viewPrepare{
    
    self.timeLineView = [[UIView alloc] init];
    self.timeLineView.hidden = YES;
    self.timeLineView.layer.cornerRadius=2;
    self.timeLineView.backgroundColor = [UIColor greenColor];
    [self addSubview:self.timeLineView];
    
    self.duration_Total = 8;
    self.duration_Least = 4;
}



/** 开始录制 */
-(void)startRecord{
    
    if (self.isRecord) return;
    
    [self.timeLineView.layer removeAllAnimations];
    self.timeLineView.hidden = NO;
    
    self.isRecord = YES;
    
    //删除本地文件
    NSError *error = [self deleteCaches];
    
    if(error == nil){
        
        //清空路径
        self.CoreVideoCacheFolderPath = nil;
        _videoFilePath_MOV = nil;
        _videoFilePath_MP4 = nil;
        
    }else{
        
        NSLog(@"删除错误：%@",error.localizedDescription);
        
        return;
    }
    
    
    AVAudioSession *avSession = [AVAudioSession sharedInstance];
    
    [avSession requestRecordPermission:^(BOOL available) {
        
        if (available) {
            
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"无法录音" message:@"请在“设置-隐私-麦克风”选项中允许xx访问你的麦克风" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
            });
            
            return;
        }
    }];
    
    self.timeLineView.hidden = NO;
    CGRect frame = self.timeLineView.frame;
    frame.size.width= 0;
    CGSize size = self.bounds.size;
    CGFloat px = size.width/2;
    CGFloat py = size.height - frame.size.height / 2;
    [UIView animateWithDuration:self.duration_Total animations:^{
        
        self.timeLineView.center = CGPointMake(px, py);
        self.timeLineView.bounds = frame;
        
    } completion:^(BOOL finished) {
        
        if(finished)[self finishRecord];
        
        self.timeLineView.frame = CGRectZero;
        self.timeLineView.hidden = YES;
    }];
    
    
    [self.videoModel beginRecordSaveToTheDocumentFilePath:self.videoFilePath_MOV];
    
    //记录开始时间
    self.beginTime = [NSDate date].timeIntervalSince1970;
    
    if ([self.delegate respondsToSelector:@selector(coreViewDidStartRecord)])[self.delegate coreViewDidStartRecord];
}



- (void)finishRecord {
    
    //结束时间
    
    NSTimeInterval now = [NSDate date].timeIntervalSince1970;
    
    NSTimeInterval minus = now - self.beginTime;
    
    self.recordTime_real = minus;
    
    NSLog(@"开始时间：%f. 结束时间：%f",self.beginTime, now);
    
    NSLog(@"时间差:%f,%f",minus,self.recordTime_real);
    
    if(self.recordTime_real < self.duration_Least) {
        
        if([self.delegate respondsToSelector:@selector(coreViewRecordIsTooShort)]){[self.delegate coreViewRecordIsTooShort];}
        
        NSLog(@"时间太短：%f",self.recordTime_real);
        [self resetUI];
        return;
    }else {
        
        NSLog(@"时间够长：%f",self.recordTime_real);
    }
    
    NSLog(@"%f",self.recordTime_real);
    
    self.isRecord = NO;
    [self.timeLineView.layer removeAllAnimations];
    self.timeLineView.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"animationEnd" object:nil];
    
    if ([self.delegate respondsToSelector:@selector(coreView:didFinishRecordWithMOVFilePath:)])[self.delegate coreView:self didFinishRecordWithMOVFilePath:self.videoFilePath_MOV];
}



- (void)cancelRecord {
    NSLog(@"cancelRecord");
    [self resetUI];
    if(!self.isRecord){return;}
    if ([self.delegate respondsToSelector:@selector(coreViewDidCancelRecord)])[self.delegate coreViewDidCancelRecord];
}


-(void)resetUI{
    
    self.beginTime = 0;
    self.recordTime_real = 0;
    self.isRecord = NO;
    [self.timeLineView.layer removeAllAnimations];
    self.timeLineView.hidden = YES;
}

-(void)layoutSubviews{
    
    [super layoutSubviews];
    
    CGSize size = self.bounds.size;
    
    [self.layer.sublayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if([obj isKindOfClass:[AVCaptureVideoPreviewLayer class]]){
            obj.frame = self.bounds;
        }
    }];
    
    
    if (self.isRecord) return;
    
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CGFloat x = 0;
        CGFloat h = 4;
        CGFloat y = size.height - h;
        CGFloat w = size.width;
        CGRect frame = CGRectMake(x, y, w, h);
        
        obj.frame = frame;
        [self bringSubviewToFront:obj];
    }];
}


-(NSString *)videoFilePath_MOV{
    
    if(_videoFilePath_MOV == nil){
        
        _videoFilePath_MOV = [self.CoreVideoCacheFolderPath stringByAppendingPathComponent:@"video.mov"];
        
    }
    
    return _videoFilePath_MOV;
}


-(NSString *)videoFilePath_MP4{
    
    if(_videoFilePath_MP4 == nil){
        
        _videoFilePath_MP4 = [self.CoreVideoCacheFolderPath stringByAppendingPathComponent:@"video.mp4"];
    }
    
    return _videoFilePath_MP4;
    
}


-(CoreVideoModel *)videoModel{
    
    if(_videoModel == nil){
        
        _videoModel = [CoreVideoModel new];
        
    }
    
    return _videoModel;
    
}


-(NSString *)CoreVideoCacheFolderPath{
    
    if(_CoreVideoCacheFolderPath == nil){
        
        _CoreVideoCacheFolderPath = [[NSString cachesFolder] createSubFolder:@"CoreVideo"];
    }
    
    return _CoreVideoCacheFolderPath;
}


/** 删除缓存 */
-(NSError *)deleteCaches{
    
    return [self.CoreVideoCacheFolderPath deleteFileOrFloder];
}



/** 删除MOV */
-(NSError *)deleteMOVFile{
    
    return [self.videoFilePath_MOV deleteFileOrFloder];
}



/** 删除MP4 */
-(NSError *)deleteMP4File{
    
    return [self.videoFilePath_MP4 deleteFileOrFloder];
}


-(void)convertMP4WithCompleteBlock:(void(^)(NSString *mp4FilePath))completeBlock errorBlock:(void(^)())errorBlock{
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)),dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:self.videoFilePath_MOV] options:nil];
                
                NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
                
                if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality]) {
                    
                    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
                    exportSession.outputURL = [NSURL fileURLWithPath:self.videoFilePath_MP4];
                    exportSession.outputFileType = AVFileTypeMPEG4;
                    
                    
                    [exportSession exportAsynchronouslyWithCompletionHandler:^(void){
                        
                        switch (exportSession.status) {
                                
                            case AVAssetExportSessionStatusUnknown:
                                NSLog(@"AVAssetExportSessionStatusUnknown");
                                if(errorBlock != nil) errorBlock();
                                break;
                                
                            case AVAssetExportSessionStatusWaiting:
                                NSLog(@"AVAssetExportSessionStatusWaiting");
                                if(errorBlock != nil) errorBlock();
                                break;
                                
                            case AVAssetExportSessionStatusExporting:
                                NSLog(@"AVAssetExportSessionStatusExporting");
                                if(errorBlock != nil) errorBlock();
                                break;
                                
                            case AVAssetExportSessionStatusFailed:
                                NSLog(@"AVAssetExportSessionStatusFailed error:%@", exportSession.error.localizedDescription);
                                if(errorBlock != nil) errorBlock();
                                break;
                                
                            case AVAssetExportSessionStatusCompleted:
                                
                                if(completeBlock != nil) completeBlock(self.videoFilePath_MP4);
                                
                                //删除MOV高清文件
                                [self deleteMOVFile];
                                
                                break;
                                
                            default:
                                if(errorBlock != nil) errorBlock();
                                break;
                        }
                    }];
                }
            });
        });
        
    });
}



/** 准备 */
-(void)prepare{
    
    [self.videoModel setRecVideoAndVideoPreviewLayer:self];
}


/** MOV文件大小 */
-(CGFloat)getVideoFileSize_MOV{
    
    return [self getFileSize:self.videoFilePath_MOV];
}

/** MP4文件大小 */
-(CGFloat)getVideoFileSize_MP4{
    
    return [self getFileSize:self.videoFilePath_MP4];
}


- (CGFloat)getFileSize:(NSString *)path
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    float filesize = -1.0;
    if ([fileManager fileExistsAtPath:path]) {
        NSDictionary *fileDic = [fileManager attributesOfItemAtPath:path error:nil];//获取文件的属性
        unsigned long long size = [[fileDic objectForKey:NSFileSize] longLongValue];
        filesize = 1.0*size/(1024 * 1024);
    }
    return filesize;
}


/** 获取视频截图 */
-(UIImage *)getVideoImage_MOV{
    return [self getImage:self.videoFilePath_MOV];
}

/** 获取视频截图 */
-(UIImage *)getVideoImage_MP4{
    return [self getImage:self.videoFilePath_MP4];
}


-(UIImage *)getImage:(NSString *)videoURL{
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:videoURL];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:url options:opts];
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
    generator.appliesPreferredTrackTransform = YES;
    NSError *error = nil;
    CGImageRef img = [generator copyCGImageAtTime:CMTimeMake(0, 1) actualTime:NULL error:&error];
    UIImage *image = [UIImage imageWithCGImage: img];
    return image;
}

/** 保存到系统相册 */
-(void)save_MOV_ToAlbumWithCompleteBlock:(void(^)(NSError *error))completeBlock{
    self.SaveAblumResBlock = completeBlock;
    [self saveAlbum:self.videoFilePath_MOV];
}

/** 保存到系统相册 */
-(void)save_MP4_ToAlbumWithCompleteBlock:(void(^)(NSError *error))completeBlock{
    self.SaveAblumResBlock = completeBlock;
    [self saveAlbum:self.videoFilePath_MP4];
}

-(void)saveAlbum:(NSString *)videoURL{
    UISaveVideoAtPathToSavedPhotosAlbum(videoURL, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
}


- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo: (void *) contextInfo {
    if(self.SaveAblumResBlock != nil) self.SaveAblumResBlock(error);
}

@end
