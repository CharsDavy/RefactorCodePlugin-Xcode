//
//  DZConfig.h
//  RefactorCodePlugin
//
//  Created by chars on 16/3/17.
//  Copyright © 2016年 chars. All rights reserved.
//

#ifndef DZConfig_h
#define DZConfig_h

//custom log
#ifdef DEBUG
//debug
#define DZLog(...) NSLog(@"%s line:%d\n %@ \n\n", __func__, __LINE__, [NSString stringWithFormat:__VA_ARGS__])
#else
//release
#define DZLog(...)
#endif

#endif /* DZConfig_h */
