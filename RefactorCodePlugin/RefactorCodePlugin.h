//
//  RefactorCodePlugin.h
//  RefactorCodePlugin
//
//  Created by chars on 16/3/17.
//  Copyright © 2016年 chars. All rights reserved.
//

#import <AppKit/AppKit.h>

@class RefactorCodePlugin;

static RefactorCodePlugin *sharedPlugin;

@interface RefactorCodePlugin : NSObject

+ (instancetype)sharedPlugin;
- (id)initWithBundle:(NSBundle *)plugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end