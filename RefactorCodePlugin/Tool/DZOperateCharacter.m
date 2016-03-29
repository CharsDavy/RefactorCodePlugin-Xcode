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
    NSRange verify = {0};
    DZLog(@"result:%zi", results.count);
    
    for (NSTextCheckingResult *result in results) {
        DZLog(@"%@ %@", NSStringFromRange(result.range), [content substringWithRange:result.range]);
        DZResults *ret = [[DZResults alloc] init];
        verify = [[content substringWithRange:result.range] rangeOfString:@"forKey" options:NSCaseInsensitiveSearch];
        if (verify.length > 0) {
            continue;
        }
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
    
    NSArray *verify = nil;
    NSTextCheckingResult *result = nil;
    do {
        result = [regular firstMatchInString:content options:0 range:NSMakeRange(currentIdx, content.length - currentIdx)];
        DZLog(@"%zi", content.length);
        if (!result) {
            DZLog(@"findSpecityContentWithFilePath Error!");
            return NULL;
        }
        DZLog(@"%@ %@", NSStringFromRange(result.range), [content substringWithRange:result.range]);
        
        currentIdx = result.range.location + result.range.length;
        verify = [self findAllSpecityStringWithContent:[content substringWithRange:result.range] pattern:@"(?<=for)(.+)(\\:)"];
        
        ret.resultString = [content substringWithRange:result.range];
        ret.resultRange = result.range;
    } while (verify.count > 0);
    
    return ret;
}

+ (void)zeroCurrentIdx
{
    currentIdx = 0;
}

+ (DZResults *)createSetterMethodReplaceStringWithSpecityString:(NSString *)specity
{
    DZResults *ret = [[DZResults alloc] init];
    
    NSArray *header = [self createSetterMethodHeaderReplaceStringWithSpecityString:specity];
    NSString *value = [self createSetterMethodValueReplaceStringWithSpecityString:specity];
    NSString *tail = [self createSetterMethodTailReplaceStringWithSpecityString:specity];
    NSString *change = [[NSString alloc] initWithFormat:@"%@%@", [[value substringToIndex:1] lowercaseString], [value substringWithRange:NSMakeRange(1, value.length - 1)]];
    
    ret.resultString = [[NSString alloc] initWithFormat:@"%@.%@ = %@;", (NSString *)[header lastObject], change, tail];
    
    return ret;
}

+ (NSString *)createSetterMethodValueReplaceStringWithSpecityString:(NSString *)specity
{
    NSError *error = nil;
    NSString *valuePattern =  [[NSString alloc] initWithFormat:@"%@", @"(?<=set)(\\w+)(?=:)"];
    
    //According to the regular expression，set up Objective-C rules
    NSRegularExpression *valueRegular = [[NSRegularExpression alloc] initWithPattern:valuePattern options:NSRegularExpressionAllowCommentsAndWhitespace error:&error];
    if (error) {
        DZLog(@"create replace string value regular error:%@",error);
    }
    NSTextCheckingResult *value = [valueRegular firstMatchInString:specity options:0 range:NSMakeRange(0, specity.length)];
    if (!value) {
        DZLog(@"createSetterMethodHeaderReplaceStringWithSpecityString Value Error!");
        return NULL;
    }
    
    NSString *valueReplace = [[NSString alloc] initWithFormat:@"%@", [specity substringWithRange:value.range]];
    
    return valueReplace;
}

+ (NSString *)createSetterMethodTailReplaceStringWithSpecityString:(NSString *)specity
{
    NSError *error = nil;
    NSString *tailPattern = [[NSString alloc] initWithFormat:@"%@", @"(?<=\\:)(.+)(?=\\])"];
    
    //According to the regular expression，set up Objective-C rules
    NSRegularExpression *tailRegular = [[NSRegularExpression alloc] initWithPattern:tailPattern options:NSRegularExpressionAllowCommentsAndWhitespace error:&error];
    if (error) {
        DZLog(@"create replace string tail regular error:%@",error);
    }
    NSTextCheckingResult *tail = [tailRegular firstMatchInString:specity options:0 range:NSMakeRange(0, specity.length)];
    if (!tail) {
        DZLog(@"createSetterMethodHeaderReplaceStringWithSpecityString Tail Error!");
        return NULL;
    }
    
    NSString *tailReplace = [[NSString alloc] initWithFormat:@"%@", [specity substringWithRange:tail.range]];
    
    return tailReplace;
}

+ (NSArray *)createSetterMethodHeaderReplaceStringWithSpecityString:(NSString *)src
{
    NSMutableArray *arrayM = [NSMutableArray array];
    NSArray *brace = nil; //大括号
    NSArray *bracket = nil; //中括号
    NSArray *parenthesis = nil; //小括号
    NSArray *setter = [self findAllSpecityStringWithContent:src pattern:@"\\s*set"];
    
    brace = [self findAllSpecityStringWithContent:src pattern:@"\\{"];
    bracket = [self findAllSpecityStringWithContent:src pattern:@"\\["];
    parenthesis = [self findAllSpecityStringWithContent:src pattern:@"\\("];
    
    for (DZResults *result in setter) {

        NSString *currentSrc = [src substringWithRange:NSMakeRange(0, result.resultRange.location)];
        if (bracket.count) {
            NSArray *tmp = [self findAllSpecityStringWithContent:currentSrc pattern:@"\\]"];
            NSUInteger i = 0;
            if (tmp.count) {
                i = bracket.count - tmp.count;
            }
            DZResults *currentResult = (DZResults *)bracket[i];
            DZResults *currentFindResult = (DZResults *)[tmp lastObject];
            NSUInteger start = currentResult.resultRange.location + currentResult.resultRange.length;
            NSUInteger length = currentSrc.length - start;
            if (currentFindResult) {
                start = currentResult.resultRange.location;
                length = currentFindResult.resultRange.location + currentFindResult.resultRange.length - start;
            }
            NSString *header = [currentSrc substringWithRange:NSMakeRange(start, length)];
            [arrayM addObject:header];
        } else if (parenthesis.count) {
            
        } else if (brace.count) {
            
        } else {
            DZLog(@"Bracket Operate Error!");
        }

    }

    return arrayM;
}

@end
