//
//  RefactorCodePlugin.m
//  RefactorCodePlugin
//
//  Created by chars on 16/3/17.
//  Copyright © 2016年 chars. All rights reserved.
//

#import "RefactorCodePlugin.h"
#import "DZOperateController.h"
#import "DZOperateCharacter.h"
#import <objc/runtime.h>
#import "DZResults.h"

static const char hilightStateKey;
NSString *DZCurrentFilePathChangeNotification = @"transition from one file to another";

@interface RefactorCodePlugin()<DZOperateDelegate>

@property (nonatomic, strong, readwrite) NSBundle *bundle;
@property (nonatomic, readonly) DZOperateController *operateController;

@property (nonatomic, strong) NSColor *highlightColor;
@property (nonatomic, unsafe_unretained) NSTextView *sourceTextView;
@property (nonatomic, copy) NSString *selectedText;
@property (nonatomic, readonly) NSString *string;
@property (nonatomic, assign) NSRange selectedRange;

@property (nonatomic, copy) NSString *filePath;

@property (nonatomic, assign) BOOL flag;

@end

@implementation RefactorCodePlugin

@synthesize operateController = _operateController;

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

#pragma mark - Internal

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource access
        self.bundle = plugin;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didApplicationFinishLaunchingNotification:)name:NSApplicationDidFinishLaunchingNotification object:nil];
    }
    return self;
}

-(DZOperateController *)operateController
{
    if (_operateController == nil) {
        _operateController = [[DZOperateController alloc] init];
        _operateController.delegate = self;
    }
    return _operateController;
}

#pragma mark - Notification

- (void)didApplicationFinishLaunchingNotification:(NSNotification *)notify
{
    //removeObserver
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    
    // addObserver
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(filePathObtain:) name:DZCurrentFilePathChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectionDidChange:) name:NSTextViewDidChangeSelectionNotification object:nil];
    // Create menu items, initialize UI, etc.
    // Init Config
    [self initConfig];
    // Menu Item:
    [self setupMenuItem];
    
}

- (void)filePathObtain:(NSNotification *)notify
{
    //Get the file path
    NSURL *originURL = [[notify.object valueForKey:@"next"] valueForKey:@"documentURL"];
    if (originURL != nil && [originURL absoluteString].length >= 7 ) {
        if (![self.filePath isEqualToString:[originURL.absoluteString substringFromIndex:7]]) {
            [DZOperateCharacter zeroCurrentIdx];
        }
        self.filePath = [originURL.absoluteString substringFromIndex:7];
        DZLog(@"filePath is : %@", self.filePath);
    }
}

-(void)selectionDidChange:(NSNotification *)notify {
    if (!self.sourceTextView) {
        self.sourceTextView = [notify object];
    }
    
    if ([[notify object] isKindOfClass:[NSTextView class]]) {
        NSTextView *textView = [notify object];
        NSString *className = NSStringFromClass([textView class]);
        
        /**
         *  DVTSourceTextView ： 代码编辑器
         *  IDEConsoleTextView ： 控制台
         */
        if ([className isEqualToString:@"DVTSourceTextView"]) {
            if (self.sourceTextView != textView) {
                self.sourceTextView = textView;
            }
            
            //延迟0.1秒执行高亮
            [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(todoHighlighting) object:nil];
            [self performSelector:@selector(todoHighlighting) withObject:nil afterDelay:0.1f];
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Actions

#pragma mark Init Config

-(void) initConfig
{
    _highlightColor = [NSColor colorWithCalibratedRed:1.000 green:0.992 blue:0.518 alpha:1.000];
}

#pragma mark Build Menu

-(void) setupMenuItem
{
    // Menu Item:
    
    NSMenuItem *editMenuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    
    if (editMenuItem) {
        [[editMenuItem submenu] addItem:[NSMenuItem separatorItem]];
        
        NSMenu *refactorCodeMenu = [[NSMenu alloc] initWithTitle:@"Refactor Code"];
        
        NSMenuItem *menuItem;
        menuItem = [[NSMenuItem alloc] initWithTitle:@"Refactor Method Style" action:@selector(refactorMethodStyleMenuAction) keyEquivalent:@""];
        [menuItem setTarget:self];
        [refactorCodeMenu addItem:menuItem];
        
        NSMenuItem *refactorCodeMenuItem = [[NSMenuItem alloc] initWithTitle:@"Refactor Code" action:nil keyEquivalent:@""];
        [refactorCodeMenuItem setSubmenu:refactorCodeMenu];
        [[editMenuItem submenu] addItem:refactorCodeMenuItem];
    }
}

#pragma mark Show Operate Window

- (void)refactorMethodStyleMenuAction
{
    [self.operateController showWindow:nil];
    
    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"DZOperateController" withExtension:@"nib"];
    
    if (!url) {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Refactor Method Style could not be shown because the plugin is corrupted.";
        alert.informativeText = @"If you built the plugin from sources using Xcode, make sure to perform “Clean Build Folder“ in Xcode and then build the plugin again.\n\nIf you installed the plugin via Alctraz, there is a pending issue causing some files to be missing in the plugin. Prefer to install it via the plugin webpage.";
        [alert addButtonWithTitle:@"Download Latest"];
        [alert addButtonWithTitle:@"Cancel"];
        NSModalResponse result = [alert runModal];
        
        if (result == NSAlertFirstButtonReturn) {
            [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/CharsDavy/RefactorCodePlugin-Xcode"]];
        }
    }
}

#pragma mark Update Preview Content

- (void)updatePreviewContentWithString:(NSString *)string
{
    [self.operateController.preview.textStorage beginEditing];
    NSDictionary *attrsDict = @{NSTextEffectAttributeName: NSTextEffectLetterpressStyle};
    NSMutableAttributedString *mutableAttrString = [[NSMutableAttributedString alloc] initWithString:@"" attributes:attrsDict];
    NSAttributedString *appendAttrString = [[NSAttributedString alloc] initWithString:string];
    [mutableAttrString appendAttributedString:appendAttrString];
    [self.operateController.preview.textStorage setAttributedString:mutableAttrString];
    [self.operateController.preview.textStorage endEditing];
}

#pragma mark Replace SourceTextView Content

- (void)replaceSourceTextViewContentWithString:(NSString *)string
{
    [self.sourceTextView.textStorage beginEditing];
    NSDictionary *attrsDict = @{NSTextEffectAttributeName: NSTextEffectLetterpressStyle};
    NSMutableAttributedString *mutableAttrString = [[NSMutableAttributedString alloc] initWithString:@"" attributes:attrsDict];
    NSAttributedString *replaceAttrString = [[NSAttributedString alloc] initWithString:string];
    [mutableAttrString appendAttributedString:replaceAttrString];
    [self.sourceTextView.textStorage setAttributedString:mutableAttrString];
    [self.sourceTextView.textStorage endEditing];
}

#pragma mark todoHighlight

- (void)todoHighlighting
{
    [self highlightSelectedStrings];
}

- (NSString *)selectedText
{
    NSTextView *textView = self.sourceTextView;
    NSRange selectedRange = [textView selectedRange];
    NSString *text = textView.textStorage.string;

    if (_selectedRange.length > 0 && (_selectedRange.location + _selectedRange.length) <= text.length) {
        selectedRange = _selectedRange;
    }
    
    NSString *nSelectedStr = [[text substringWithRange:selectedRange] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" \n"]];
    
    //如果新选中的长度为0 就返回空
    if (!nSelectedStr.length) {
        return @"";
    }
    
    _selectedText = nSelectedStr;
    
    return _selectedText;
}

#pragma mark Highlighting

- (void)highlightSelectedStrings
{
    //每次高亮 都撤销之前高亮
    [self removeAllHighlighting];
    
    NSArray *array = [self rangesOfString:self.selectedText];
    
    [self addBackgroundColorWithRangeArray:array];
}

- (void)addBackgroundColorWithRangeArray:(NSArray *)rangeArray
{
    NSTextView *textView = self.sourceTextView;
    
    [rangeArray enumerateObjectsUsingBlock:^(NSValue *value, NSUInteger idx, BOOL *stop) {
        NSRange range = [value rangeValue];
        [textView.layoutManager addTemporaryAttribute:NSBackgroundColorAttributeName value:_highlightColor forCharacterRange:range];
    }];
    
    [textView setNeedsDisplay:YES];
    if (textView) {
        objc_setAssociatedObject(textView, &hilightStateKey, @"1", OBJC_ASSOCIATION_COPY);
    }
}

- (NSMutableArray *)rangesOfString:(NSString *)string
{
    if (string.length == 0) {
        return nil;
    }
    
    NSUInteger length = [self.string length];
    
    NSRange searchRange = NSMakeRange(0, length);
    NSRange foundRange = NSMakeRange(0, 0);
    
    NSMutableArray *rangArray = [NSMutableArray array];
    
    while (YES) {
        foundRange = [self.string rangeOfString:string options:0 range:searchRange];
        NSUInteger searchRangeStart = foundRange.location + foundRange.length;
        searchRange = NSMakeRange(searchRangeStart, length - searchRangeStart);
        
        if (foundRange.location != NSNotFound) {
            [rangArray addObject:[NSValue valueWithRange:foundRange]];
        } else {
            break;
        }
    }
    return rangArray;
}

- (void)removeAllHighlighting
{
    NSUInteger length = [[self.textStorage string] length];
    NSTextView *textView = self.sourceTextView;
    
    NSString *hilightState = objc_getAssociatedObject(textView, &hilightStateKey);
    if (![hilightState boolValue]) {
        return;
    }
    
    NSRange range = NSMakeRange(0, 0);
    for (int i = 0; i < length;) {
        NSDictionary *dict = [textView.layoutManager temporaryAttributesAtCharacterIndex:i effectiveRange:&range];
        id obj = dict[NSBackgroundColorAttributeName];
        if (obj && [_highlightColor isEqual:obj]) {
            [textView.layoutManager removeTemporaryAttribute:NSBackgroundColorAttributeName forCharacterRange:range];
        }
        i += range.length;
    }
    
    [textView setNeedsDisplay:YES];
    
    if (textView) {
        objc_setAssociatedObject(textView, &hilightStateKey, @"0", OBJC_ASSOCIATION_RETAIN);
    }
}

#pragma mark - DZOperateDelegate

- (void)operateSetterStyleAction
{
    NSMutableString *origin = [[NSMutableString alloc] initWithString:self.string];
    NSString *replace = [origin stringByReplacingCharactersInRange:_selectedRange withString:@"[menuItem setTarget:test];"];
    [self replaceSourceTextViewContentWithString:replace];
    DZLog(@"operateSetterStyleAction in plugin");
}

- (void)operateNSArrayStyleAction
{
    DZLog(@"operateNSArrayStyleAction in plugin");
}

- (void)operateNSDictionaryStyleAction
{
    DZLog(@"operateNSDictionaryStyleAction in plugin");
}

- (void)findAllSpecifyStringWithPattern:(NSString *)pattern
{
    NSArray *array = [DZOperateCharacter findAllSpecityContentWithFilePath:self.filePath pattern:pattern];
    NSMutableString *preview = [NSMutableString string];
    for (DZResults *find in array) {
        [preview appendFormat:@"%@\n", find.resultString];
    }
    
    if (preview) {
        [self updatePreviewContentWithString:preview];
    }else {
        [self updatePreviewContentWithString:@"Finished"];
    }
    DZLog(@"findSpecifyStringWithPattern: in plugin");
}

- (void)findSpecifyStringWithPattern:(NSString *)pattern
{
    DZResults *find = [DZOperateCharacter findSpecityContentWithFilePath:self.filePath pattern:pattern];
    if (find) {
        [self updatePreviewContentWithString:[NSString stringWithFormat:@"%@\n", find.resultString]];
        _selectedRange = find.resultRange;
    }else {
        [self updatePreviewContentWithString:[NSString stringWithFormat:@"\nFinished"]];
    }
    DZLog(@"findSpecifyStringWithPattern: in plugin");
    [self todoHighlighting];
}

#pragma mark - Accessor Overrides
- (NSTextStorage *)textStorage
{
    return [self.sourceTextView textStorage];
}

- (NSString *)string
{
    return [self.textStorage string];
}

#pragma mark - Test

- (void)test
{
    //[  [self.dsadas dsds] setSSSS : dsads    ];
    [self setValue:[NSString stringWithFormat:@"%@", @"ssssss"] forKey:@"ddd"];
    [NSString stringWithFormat:@"%@", @"ssssss"];
    [self setFilePath:@"/Users/chars/Xcode_code/RefactorCodePlugin/RefactorCodePlugin/Core/RefactorCodePlugin.m"];
    [self setFlag:YES];
    NSArray *array = [NSArray arrayWithObjects:@"1", @"2", @"3", nil];
    array = [NSArray arrayWithContentsOfFile:@"xxxxx"];
    array = [NSArray arrayWithContentsOfURL:[NSURL URLWithString:@"myzaker.com"]];
    NSDictionary *dict = [NSDictionary dictionaryWithObject:@"davy" forKey:@"name"];
    NSDictionary *dict1 = [NSDictionary dictionaryWithObject:@"davy" forKey:@"name"];
    NSDictionary *dict2 = [NSDictionary dictionaryWithObject:@"davy" forKey:@"name"];
    NSDictionary *dict3 = [NSDictionary dictionaryWithObject:@"davy" forKey:@"name"];
    NSDictionary *dict4 = [NSDictionary dictionaryWithObject:@"davy" forKey:@"name"];
    NSDictionary *dict5 = [NSDictionary dictionaryWithObject:@"davy" forKey:@"name"];
    NSDictionary *dict6 = [NSDictionary dictionaryWithObject:@"davy" forKey:@"name"];
    NSDictionary *dict7 = [NSDictionary dictionaryWithObject:@"davy" forKey:@"name"];
    NSDictionary *dict8 = [NSDictionary dictionaryWithObject:@"davy" forKey:@"name"];
    NSDictionary *dict9 = [NSDictionary dictionaryWithObject:@"davy" forKey:@"name"];
    NSDictionary *dict10 = [NSDictionary dictionaryWithObject:@"davy" forKey:@"name"];
    NSDictionary *dict11 = [NSDictionary dictionaryWithObject:@"davy" forKey:@"name"];
    NSDictionary *dict12 = [NSDictionary dictionaryWithObject:@"davy" forKey:@"name"];
    NSDictionary *dict13 = [NSDictionary dictionaryWithObject:@"davy" forKey:@"name"];
    NSDictionary *dict14 = [NSDictionary dictionaryWithObject:@"davy" forKey:@"name"];
    NSDictionary *dict15 = [NSDictionary dictionaryWithObject:@"davy" forKey:@"name"];
    NSDictionary *dict16 = [NSDictionary dictionaryWithObject:@"davy" forKey:@"name"];
}

@end
