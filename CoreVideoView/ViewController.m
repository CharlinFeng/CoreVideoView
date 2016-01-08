//
//  ViewController.m
//  CoreVideoView
//
//  Created by 冯成林 on 16/1/8.
//  Copyright © 2016年 冯成林. All rights reserved.
//

#import "ViewController.h"
#import "CoreVideoView.h"
#import "NSString+CoreVideoFile.h"

@interface ViewController ()<CoreVideoViewDelegate>

@property (weak, nonatomic) IBOutlet CoreVideoView *videoView;

@property (weak, nonatomic) IBOutlet UIImageView *imageV;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.videoView prepare];
    self.videoView.duration = 8;
    self.videoView.delegate = self;
}

- (IBAction)recordAction:(id)sender {
    
    [self.videoView startRecord];
}



-(void)coreViewDidStartRecord{

    NSLog(@"开始录制");
}


-(void)coreView:(CoreVideoView *)coreView didFinishRecordWithMOVFilePath:(NSString *)movFilePath{

    NSLog(@"完成录制(MOV: %.2fMB):%@",coreView.getVideoFileSize_MOV,movFilePath);
    
  
 
    [coreView convertMP4WithCompleteBlock:^(NSString *mp4FilePath) {
        
        NSLog(@"转换完成(MP4: %.2fMB):%@",coreView.getVideoFileSize_MP4,mp4FilePath);
        
        if(mp4FilePath.isFileExists){
            
            NSLog(@"mp4文件存在");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageV.image = coreView.getVideoImage_MP4;
            });
        }
    }];
}




-(void)coreViewDidCancelRecord{

    NSLog(@"取消录制");
    
}

@end
