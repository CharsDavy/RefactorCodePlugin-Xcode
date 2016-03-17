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

#pragma mark Find Button Action

- (IBAction)findButtonAction:(NSButton *)sender
{
    NSString *selectedStyle = [[NSUserDefaults standardUserDefaults] stringForKey:DZDefaultsKeyMethodStyle];
    NSString *pattern = [[NSString alloc] init];
    
    if ([selectedStyle isEqualToString:@"Setter"]) {
        pattern = DZSetterMethodRegexPattern;
    }else if ([selectedStyle isEqualToString:@"NSArray"]) {
        pattern = DZNSArrayMethodRegexPattern;
    }else if ([selectedStyle isEqualToString:@"NSDictionary"]) {
        pattern = DZNSDictionaryMethodRegexPattern;
    }else {
        DZLog(@"findButtonAction Error!");
    }
    
    if ([_delegate respondsToSelector:@selector(findAllSpecifyStringWithPattern:)]) {
        [_delegate findAllSpecifyStringWithPattern:pattern];
    }
    DZLog(@"pattern : %@", pattern);
}

#pragma mark Apply Button Action

- (IBAction)applyButtonAction:(NSButton *)sender
{
    NSString *selectedStyle = [[NSUserDefaults standardUserDefaults] stringForKey:DZDefaultsKeyMethodStyle];
    if ([selectedStyle isEqualToString:@"Setter"]) {
        if ([_delegate respondsToSelector:@selector(operateSetterStyleAction)]) {
            [_delegate operateSetterStyleAction];
        }
        DZLog(@"Style is Setter");
    }else if ([selectedStyle isEqualToString:@"NSArray"]) {
        if ([_delegate respondsToSelector:@selector(operateNSArrayStyleAction)]) {
            [_delegate operateNSArrayStyleAction];
        }
        DZLog(@"Style is NSArray");
    }else if ([selectedStyle isEqualToString:@"NSDictionary"]) {
        if ([_delegate respondsToSelector:@selector(operateNSDictionaryStyleAction)]) {
            [_delegate operateNSDictionaryStyleAction];
        }
        DZLog(@"Style is NSDictionary");
    }else {
        DZLog(@"changeButtonAction Error!");
    }
}

#pragma mark Next Button Action
- (IBAction)nextButtonAction:(NSButton *)sender
{
    NSString *selectedStyle = [[NSUserDefaults standardUserDefaults] stringForKey:DZDefaultsKeyMethodStyle];
    NSString *pattern = [[NSString alloc] init];
    
    if ([selectedStyle isEqualToString:@"Setter"]) {
        pattern = DZSetterMethodRegexPattern;
    }else if ([selectedStyle isEqualToString:@"NSArray"]) {
        pattern = DZNSArrayMethodRegexPattern;
    }else if ([selectedStyle isEqualToString:@"NSDictionary"]) {
        pattern = DZNSDictionaryMethodRegexPattern;
    }else {
        DZLog(@"findButtonAction Error!");
    }
    
    if ([_delegate respondsToSelector:@selector(findSpecifyStringWithPattern:)]) {
        [_delegate findSpecifyStringWithPattern:pattern];
    }
    DZLog(@"pattern : %@", pattern);
}

@end
