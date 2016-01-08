//
//  ViewController.h
//  CoreVideoView
//
//  Created by 冯成林 on 16/1/8.
//  Copyright © 2016年 冯成林. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (CoreVideoFile)



/** 路径对应文件是否存在 */
@property (nonatomic,assign) BOOL isFileExists;





/*
 *  document根文件夹
 */
+(NSString *)documentFolder;


/*
 *  caches根文件夹
 */
+(NSString *)cachesFolder;




/**
 *  生成子文件夹
 *
 *  如果子文件夹不存在，则直接创建；如果已经存在，则直接返回
 *
 *  @param subFolder 子文件夹名
 *
 *  @return 文件夹路径
 */
-(NSString *)createSubFolder:(NSString *)subFolder;



/** 删除指定路径的文件：如果是文件，直接删除；如果是文件夹，级联删除 */
-(NSError *)deleteFileOrFloder;

@end
