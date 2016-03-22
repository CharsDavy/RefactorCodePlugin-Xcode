//
//  DZOperateCharacter.m
//  RefactorCodePlugin
//
//  Created by chars on 16/3/17.
//  Copyright © 2016年 chars. All rights reserved.
//

#import "DZOperateCharacter.h"
#import "DZResults.h"

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
    NSRegularExpression *regular = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionAllowCommentsAndWhitespace error:&error];
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
        DZResults *ret = [[DZResults alloc] init];
        ret.resultString = [fileContent substringWithRange:result.range];
        ret.resultRange = result.range;
        [arrayM addObject: ret];
    }
    
    return (NSArray *)arrayM;
}

+ (NSArray *)findAllSpecityStringWithContent:(NSString *)content pattern:(NSString *)pattern
{
    if (!content) {
        return NULL;
    }
    
    NSMutableArray *arrayM = [NSMutableArray array];
    NSError *error = nil;
    //According to the regular expression，set up Objective-C rules
    NSRegularExpression *regular = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionAllowCommentsAndWhitespace error:&error];
    if (error) {
        DZLog(@"regular error:%@",error);
    }
    
    //Test for regular
    NSArray *results = [regular matchesInString:content options:0 range:NSMakeRange(0, content.length)];
    DZLog(@"result:%zi", results.count);
    
    for (NSTextCheckingResult *result in results) {
        DZLog(@"%@ %@", NSStringFromRange(result.range), [content substringWithRange:result.range]);
        DZResults *ret = [[DZResults alloc] init];
        ret.resultString = [content substringWithRange:result.range];
        ret.resultRange = result.range;
        [arrayM addObject: ret];
    }
    
    return (NSArray *)arrayM;
}

+ (DZResults *)findSpecityStringWithContent:(NSString *)content pattern:(NSString *)pattern
{
    if (!content) {
        return NULL;
    }
    DZResults *ret = [[DZResults alloc] init];
    NSError *error = nil;
    //According to the regular expression，set up Objective-C rules
    NSRegularExpression *regular = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionAllowCommentsAndWhitespace error:&error];
    if (error) {
        DZLog(@"regular error:%@",error);
    }
    
    if (currentIdx > content.length) {
        return NULL;
    }
    
    NSTextCheckingResult *result = [regular firstMatchInString:content options:0 range:NSMakeRange(currentIdx, content.length - currentIdx)];
    DZLog(@"%zi", content.length);
    if (!result) {
        DZLog(@"findSpecityContentWithFilePath Error!");
        return NULL;
    }
    
    currentIdx = result.range.location + result.range.length;
    
    DZLog(@"%@ %@", NSStringFromRange(result.range), [content substringWithRange:result.range]);
    ret.resultString = [content substringWithRange:result.range];
    ret.resultRange = result.range;
    
    return ret;
}

+ (void)zeroCurrentIdx
{
    currentIdx = 0;
}

@end
