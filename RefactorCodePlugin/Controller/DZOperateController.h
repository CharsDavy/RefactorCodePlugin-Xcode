//
//  DZOperateController.h
//  FindReplace
//
//  Created by chars on 16/3/16.
//  Copyright © 2016年 chars. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol DZOperateDelegate <NSObject>
@required
- (void) operateSetterStyleAction;
- (void) operateNSArrayStyleAction;
- (void) operateNSDictionaryStyleAction;
- (void) findSpecifyStringWithPattern:(NSString *)pattern;
- (void) findAllSpecifyStringWithPattern:(NSString *)pattern;

@end

@interface DZOperateController : NSWindowController
@property (weak) IBOutlet NSTextField *selectedTextField;
@property (unsafe_unretained) IBOutlet NSTextView *preview;

@property (nonatomic, assign)id <DZOperateDelegate> delegate;

@end
