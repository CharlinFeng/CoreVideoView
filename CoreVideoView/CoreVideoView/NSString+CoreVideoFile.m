//
//  ViewController.h
//  CoreVideoView
//
//  Created by 冯成林 on 16/1/8.
//  Copyright © 2016年 冯成林. All rights reserved.
//

#import "NSString+CoreVideoFile.h"

@implementation NSString (CoreVideoFile)




/*
 *  document根文件夹
 */
+(NSString *)documentFolder{
    
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}



/*
 *  caches根文件夹
 */
+(NSString *)cachesFolder{
    
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}





/**
 *  生成子文件夹
 *
 *  如果子文件夹不存在，则直接创建；如果已经存在，则直接返回
 *
 *  @param subFolder 子文件夹名
 *
 *  @return 文件夹路径
 */
-(NSString *)createSubFolder:(NSString *)subFolder{
    
    NSString *subFolderPath=[NSString stringWithFormat:@"%@/%@",self,subFolder];
    
    BOOL isDir = NO;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL existed = [fileManager fileExistsAtPath:subFolderPath isDirectory:&isDir];
    
    if ( !(isDir == YES && existed == YES) )
    {
        [fileManager createDirectoryAtPath:subFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return subFolderPath;
}



-(BOOL)isFileExists{

    NSFileManager *mgr = [NSFileManager defaultManager];
    
    return [mgr fileExistsAtPath:self];
}



/** 删除指定路径的文件：如果是文件，直接删除；如果是文件夹，级联删除 */
-(NSError *)deleteFileOrFloder{

    if(!self.isFileExists) return nil;
    
    NSFileManager *mgr = [NSFileManager defaultManager];

    NSError *error = nil;
    
    [mgr removeItemAtPath:self error:&error];
    
    return error;
}




@end
