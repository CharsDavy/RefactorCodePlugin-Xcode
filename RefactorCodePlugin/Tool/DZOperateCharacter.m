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
        DZLog(@"find all specity string regular error:%@",error);
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
        DZLog(@"find specity string regular error:%@",error);
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

+ (DZResults *)createSetterMethodReplaceStringWithSpecityString:(NSString *)specity
{
    DZResults *ret = [[DZResults alloc] init];
    NSError *error = nil;
    NSString *headerPattern = [[NSString alloc] initWithFormat:@"%@", @"(\\w+\\.{0,1}\\w+)(?=\\s+set)"];
    NSString *valuePattern =  [[NSString alloc] initWithFormat:@"%@", @"(?<=set)(\\w+)(?=:)"];
    NSString *tailPattern = [[NSString alloc] initWithFormat:@"%@", @"(?<=\\:)(\\w+)" ];
    
    //According to the regular expression，set up Objective-C rules
    NSRegularExpression *headerRegular = [[NSRegularExpression alloc] initWithPattern:headerPattern options:NSRegularExpressionAllowCommentsAndWhitespace error:&error];
    if (error) {
        DZLog(@"create replace string header regular error:%@",error);
        error = nil;
    }
    NSTextCheckingResult *header = [headerRegular firstMatchInString:specity options:0 range:NSMakeRange(0, specity.length)];
    if (!header) {
        DZLog(@"createReplaceStringWithSpecityString Header Error!");
        return NULL;
    }
    
    NSRegularExpression *valueRegular = [[NSRegularExpression alloc] initWithPattern:valuePattern options:NSRegularExpressionAllowCommentsAndWhitespace error:&error];
    if (error) {
        DZLog(@"create replace string value regular error:%@",error);
        error = nil;
    }
    NSTextCheckingResult *value = [valueRegular firstMatchInString:specity options:0 range:NSMakeRange(0, specity.length)];
    if (!value) {
        DZLog(@"createReplaceStringWithSpecityString Header Error!");
        return NULL;
    }
    
    NSRegularExpression *tailRegular = [[NSRegularExpression alloc] initWithPattern:tailPattern options:NSRegularExpressionAllowCommentsAndWhitespace error:&error];
    if (error) {
        DZLog(@"create replace string tail regular error:%@",error);
    }
    NSTextCheckingResult *tail = [tailRegular firstMatchInString:specity options:0 range:NSMakeRange(0, specity.length)];
    if (!tail) {
        DZLog(@"createReplaceStringWithSpecityString Tail Error!");
        return NULL;
    }
       
    ret.resultString = [[NSString alloc] initWithFormat:@"%@.%@ = %@;", [specity substringWithRange:header.range], [[specity substringWithRange:value.range] lowercaseString], [specity substringWithRange:tail.range]];
    
    return ret;
}

@end
