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

#define DZCurrentFilePathChangeNotification @"transition from one file to another"

#define DZSetterMethodRegexPattern @"\\[self\\s+set([A-Z])([a-zA-Z])*(:)(@\"){0,1}.+(\"){0,1}(\\];)"
#define DZNSArrayMethodRegexPattern @"\\[NS(Mutable){0,1}(Array) arrayWithObject(s){0,1}:.+(\\];)"
#define DZNSDictionaryMethodRegexPattern @"\\[NS(Mutable){0,1}(Dictionary) dictionaryWithObject(s){0,1}:.+(\\];)"

/**
 *  Ruby Regular
 Setter:(\[\w+[\.]*\w*\s+(set)\w+(:)((\w+)|(\@".+))(\];))|(\[+\w+[\.]*\w*\s*\w+\]\s*\w*(set)*\]*(:)*\s*\w*(set)*(:){0,1}\s*\w*\];)
 Test string:
 [self.url setUrl:@"/Users/chars/test.m"];
 [[test.a find] setBB:partten];
 [[test.b finds] XXXsetBB:partten];
 [[[test.c findx] XXXsFFF] setXXXX:abc];
 [[[test.d findw] setSSSS] setXXXX:abce];
 [[[test findws] XXsetSSSS] XXsetXXXX:abcd];
 [self setEnable:YES];
 [self setEXXXXXnable:NO];
 
 NSArray:
 NSDictionary:
 */

#endif /* DZConstants_h */
