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
#define DZSetterMethodPattern @"self ([a-zA-Z])*set[A-Z]([a-zA-Z])*:(@)*(\")*([a-zA-Z])*(\")*"
#define DZNSArrayMethodPattern @"NS(Mutable){0,1}(Array) arrayWithObject(s){0,1}:"
#define DZNSDictionaryMethodPattern @"NS(Mutable){0,1}(Dictionary) dictionaryWithObject(s){0,1}:"


#endif /* DZConstants_h */
