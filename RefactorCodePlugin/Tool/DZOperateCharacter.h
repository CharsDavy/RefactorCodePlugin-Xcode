//
//  DZOperateCharacter.h
//  RefactorCodePlugin
//
//  Created by chars on 16/3/17.
//  Copyright © 2016年 chars. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DZOperateCharacter : NSObject

+ (NSArray *)findSpecityContentWithFilePath:(NSString *)filePath pattern:(NSString *)pattern;

@end
