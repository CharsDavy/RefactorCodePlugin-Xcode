//
//  DZOperateCharacter.m
//  RefactorCodePlugin
//
//  Created by chars on 16/3/17.
//  Copyright © 2016年 chars. All rights reserved.
//

#import "DZOperateCharacter.h"

NSUInteger currentIdx = 0;

@implementation DZOperateCharacter

+ (NSArray *)findAllSpecityContentWithFilePath:(NSString *)filePath pattern:(NSString *)pattern
{
    if (!filePath) {
        return NULL;
    }
    
    NSMutableArray *arrayM = [NSMutableArray array];
    NSError *error = nil;
    //According to the regular expression，set up Objective-C rules
    NSRegularExpression *regular = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    if (error) {
        DZLog(@"regular error:%@",error);
    }
    
    NSString *fileContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        DZLog(@"file content error:%@",error);
    }
    
    //Test for regular
    NSArray *results = [regular matchesInString:fileContent options:0 range:NSMakeRange(0, fileContent.length)];
    DZLog(@"result:%zi", results.count);
    
    for (NSTextCheckingResult *result in results) {
        DZLog(@"%@ %@", NSStringFromRange(result.range), [fileContent substringWithRange:result.range]);
        [arrayM addObject:[fileContent substringWithRange:result.range]];
    }
    
    return (NSArray *)arrayM;
}

+ (NSString *)findSpecityContentWithFilePath:(NSString *)filePath pattern:(NSString *)pattern
{
    if (!filePath) {
        return NULL;
    }
    
    NSError *error = nil;
    //According to the regular expression，set up Objective-C rules
    NSRegularExpression *regular = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    if (error) {
        DZLog(@"regular error:%@",error);
    }
    
    NSString *fileContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        DZLog(@"file content error:%@",error);
    }
    
    if (currentIdx > fileContent.length) {
        return NULL;
    }
    
    NSTextCheckingResult *result = [regular firstMatchInString:fileContent options:0 range:NSMakeRange(currentIdx, fileContent.length - currentIdx)];
    DZLog(@"%zi", fileContent.length);
    if (!result) {
        DZLog(@"findSpecityContentWithFilePath Error!");
        return NULL;
    }
    
    currentIdx = result.range.location + result.range.length;
    
    DZLog(@"%@ %@", NSStringFromRange(result.range), [fileContent substringWithRange:result.range]);
    
    return [fileContent substringWithRange:result.range];
}

@end
