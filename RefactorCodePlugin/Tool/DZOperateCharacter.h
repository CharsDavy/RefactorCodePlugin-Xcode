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

+ (NSArray *)findAllSpecityStringWithContent:(NSString *)content pattern:(NSString *)pattern;

+ (DZResults *)findSpecityStringWithContent:(NSString *)content pattern:(NSString *)pattern;

+ (void)zeroCurrentIdx;

+ (DZResults *)createSetterMethodReplaceStringWithSpecityString:(NSString *)specity;

@end
