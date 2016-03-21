//
//  DZConstants.h
//  MethodStyleChangePlugin
//
//  Created by chars on 16/3/16.
//  Copyright © 2016年 chars. All rights reserved.
//

#ifndef DZConstants_h
#define DZConstants_h

#define DZDefaultsKeyMethodStyle @"DZMethodStyle"

#define DZSetterMethodRegexPattern @"(\\[)(.+)(?<=set)[A-Z]\\w+(.+)(\\];)"
#define DZNSArrayMethodRegexPattern @"(.+)(?<=array)\\w+(.+)"
#define DZNSDictionaryMethodRegexPattern @"(.+)(?<=dictionary)\\w+(.+)"

/**
 *  Ruby Regular
 Setter:(\[\s*\w+[\.]*\w*\s+(set)\w+(:)((\w+)|(.+))(\s*\];))|((\[\s*)+\w+[\.]*\w*\s*\w+\s*\]\s*\w*(set)*\s*\]*(:)*\s*\w*(set)*(:){0,1}\s*\w*\s*\];)
 Test string:
 [self.url setUrl:@"/Users/chars/test.m"];
 [[test.a find] setBB:partten];
 [[test.b finds] XXXsetBB:partten];
 [[[test.c findx] XXXsFFF] setXXXX:abc];
 [[[test.d findw] setSSSS] setXXXX:abce];
 [[[test findws] XXsetSSSS] XXsetXXXX:abcd];
 [self setEnable:YES];
 [self setEXXXXXnable:NO];
 [self setValue:[NSString stringWithFormat:@"%@", @"ssssss"] forKey:@"ddd"];
 
 NSArray:
 NSDictionary:
 */

#endif /* DZConstants_h */
