//
//  DZOperateCharacter.h
//  RefactorCodePlugin
//
//  Created by chars on 16/3/17.
//  Copyright © 2016年 chars. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DZResults;
@interface DZOperateCharacter : NSObject

+ (NSArray *)findAllSpecityContentWithFilePath:(NSString *)filePath pattern:(NSString *)pattern;

+ (DZResults *)findSpecityContentWithFilePath:(NSString *)filePath pattern:(NSString *)pattern;

+ (void)zeroCurrentIdx;

@end
