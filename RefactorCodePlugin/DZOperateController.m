//
//  DZOperateController.m
//  FindReplace
//
//  Created by chars on 16/3/16.
//  Copyright © 2016年 chars. All rights reserved.
//

#import "DZOperateController.h"

@interface DZOperateController ()
@property (weak) IBOutlet NSPopUpButton *methodStylePopUpButton;
@property (nonatomic, copy)NSArray *styles;

@end

@implementation DZOperateController

#pragma mark - Setup and Teardown

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (NSString *)windowNibName
{
    return NSStringFromClass(self.class);
}

#pragma mark - NSWindowController

-(void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [self updateMethodStyles];
}

#pragma mark - Internal

-(NSArray *)styles
{
    if (_styles == nil) {
        _styles = [NSArray arrayWithObjects:@"Setter", @"NSArray", @"NSDictionary", nil];
    }
    return _styles;
}

- (void)updateMethodStyles
{
    [self.methodStylePopUpButton removeAllItems];
    
    NSMenuItem *menuItem = nil;
    
    for (NSString *style in self.styles) {
        menuItem = [[NSMenuItem alloc] initWithTitle:style action:nil keyEquivalent:@""];
        menuItem.representedObject = style;
        [self.methodStylePopUpButton.menu addItem:menuItem];
    }
    
    [self.methodStylePopUpButton.menu addItem:[NSMenuItem separatorItem]];
    
    NSString *selectedStyle = [[NSUserDefaults standardUserDefaults] stringForKey:DZDefaultsKeyMethodStyle];
    
    for (menuItem in self.methodStylePopUpButton.itemArray) {
        if (menuItem.representedObject && [menuItem.representedObject isEqualToString:selectedStyle]) {
            [self.methodStylePopUpButton selectItem:menuItem];
            break;
        }
    }
}

#pragma mark - Actions

#pragma mark Selected Method Style Action

- (IBAction)selectedMethodStyleAction:(NSPopUpButton *)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:sender.selectedItem.representedObject forKey:DZDefaultsKeyMethodStyle];
}

#pragma mark Change Button Action

- (IBAction)changeButtonAction:(NSPopUpButton *)sender
{
    NSString *selectedStyle = [[NSUserDefaults standardUserDefaults] stringForKey:DZDefaultsKeyMethodStyle];
    if ([selectedStyle isEqualToString:@"Setter"]) {
        //使用通知还是代理实现？根据两者特性以及现在的代码结构，选择使用代理实现。
        NSLog(@"Style is Setter");
    }else if ([selectedStyle isEqualToString:@"NSArray"]) {
        NSLog(@"Style is NSArray");
    }else if ([selectedStyle isEqualToString:@"NSDictionary"]) {
        NSLog(@"Style is NSDictionary");
    }else {
        NSLog(@"changeButtonAction Error!");
    }
}

#pragma mark Find Next Button Action

- (IBAction)findNextButtonAction:(NSPopUpButton *)sender
{
}

@end
