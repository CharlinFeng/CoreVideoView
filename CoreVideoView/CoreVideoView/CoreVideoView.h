//
//  ViewController.h
//  CoreVideoView
//
//  Created by 冯成林 on 16/1/8.
//  Copyright © 2016年 冯成林. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreVideoModel.h"

@class CoreVideoView;

@protocol CoreVideoViewDelegate <NSObject>
@optional

- (void)coreViewDidStartRecord;
- (void)coreViewDidCancelRecord;
- (void)coreView:(CoreVideoView *)coreView didFinishRecordWithMOVFilePath:(NSString *)movFilePath;

@end

@interface CoreVideoView : UIView

@property (nonatomic, strong) UIView *timeLineView;
@property (nonatomic, strong) UILabel *promptLable;
@property (nonatomic, weak) id<CoreVideoViewDelegate> delegate;

/** 录制时长 */
@property (nonatomic,assign) NSInteger duration;

/** 录制视频路径: MOV格式 */
@property (nonatomic, copy) NSString *videoFilePath_MOV;

/** 视频转码路径: MP4格式 */
@property (nonatomic, copy) NSString *videoFilePath_MP4;

/** 视频录制模型 */
@property (nonatomic, strong) CoreVideoModel *videoModel;


/** 准备 */
-(void)prepare;

/** 开始录制 */
-(void)startRecord;

/** 删除缓存 */
-(NSError *)deleteCaches;

/** 删除MOV */
-(NSError *)deleteMOVFile;

/** 删除MP4 */
-(NSError *)deleteMP4File;


-(void)convertMP4WithCompleteBlock:(void(^)(NSString *mp4FilePath))completeBlock;

/** MOV文件大小 */
-(CGFloat)getVideoFileSize_MOV;

/** MP4文件大小 */
-(CGFloat)getVideoFileSize_MP4;

/** 获取视频截图 */
-(UIImage *)getVideoImage_MOV;

/** 获取视频截图 */
-(UIImage *)getVideoImage_MP4;

/** 保存到系统相册 */
-(void)save_MOV_ToAlbumWithCompleteBlock:(void(^)(NSError *error))completeBlock;

/** 保存到系统相册 */
-(void)save_MP4_ToAlbumWithCompleteBlock:(void(^)(NSError *error))completeBlock;

@end
