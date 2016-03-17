//
//  RefactorCodePlugin.m
//  RefactorCodePlugin
//
//  Created by chars on 16/3/17.
//  Copyright © 2016年 chars. All rights reserved.
//

#import "RefactorCodePlugin.h"
#import "DZOperateController.h"

@interface RefactorCodePlugin()

@property (nonatomic, strong, readwrite) NSBundle *bundle;
@property (nonatomic, readonly)DZOperateController *operateController;
@property (nonatomic, copy)NSString *url;

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
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didApplicationFinishLaunchingNotification:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationObtain:) name:nil object:nil];
    }
    return self;
}

-(DZOperateController *)operateController
{
    if (_operateController == nil) {
        _operateController = [[DZOperateController alloc] init];
    }
    return _operateController;
}

#pragma mark - Notification

- (void)didApplicationFinishLaunchingNotification:(NSNotification*)noti
{
    //removeObserver
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    
    // Create menu items, initialize UI, etc.
    // Menu Item:
    
    NSMenuItem *editMenuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    
    if (editMenuItem) {
        [[editMenuItem submenu] addItem:[NSMenuItem separatorItem]];
        
        NSMenu *refactorCodeMenu = [[NSMenu alloc] initWithTitle:@"Refactor Code"];
        
        NSMenuItem *menuItem;
        menuItem = [[NSMenuItem alloc] initWithTitle:@"Method Style Change" action:@selector(methodStyleChangeMenuAction) keyEquivalent:@""];
        [menuItem setTarget:self];
        [refactorCodeMenu addItem:menuItem];
        
        NSMenuItem *refactorCodeMenuItem = [[NSMenuItem alloc] initWithTitle:@"Refactor Code" action:nil keyEquivalent:@""];
        [refactorCodeMenuItem setSubmenu:refactorCodeMenu];
        [[editMenuItem submenu] addItem:refactorCodeMenuItem];
    }
}

- (void)notificationObtain:(NSNotification *)notify
{
    //NSLog(@"notify:%@",notify.name);
    //Get the file path
    if ([notify.name isEqualToString:DZCurrentFilePathChangeNotification]) {
        NSURL *originURL = [[notify.object valueForKey:@"next"] valueForKey:@"documentURL"];
        if (originURL != nil && [originURL absoluteString].length >= 7 ) {
            self.url = [originURL.absoluteString substringFromIndex:7];
            NSLog(@"url is : %@", self.url);
            
            [self findSpecityContentWithPattern:DZSetterMethodPattern];
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Actions

- (void)findSpecityContentWithPattern:(NSString *)pattern
{
    NSError *error = nil;
    //According to the regular expression，set up Objective-C rules
    NSRegularExpression *regular = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    if (error) {
        NSLog(@"regular error:%@",error);
    }
    
    NSString *fileContent = [NSString stringWithContentsOfFile:self.url encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"file content error:%@",error);
    }
    
    //Test for regular
    NSArray *results = [regular matchesInString:fileContent options:0 range:NSMakeRange(0, fileContent.length)];
    NSLog(@"result:%zi", results.count);
}

#pragma mark Show Operate Window
- (void)methodStyleChangeMenuAction
{
    [self.operateController showWindow:nil];
    
    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"DZOperateController" withExtension:@"nib"];
    
    if (!url) {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Method Style Change could not be shown because the plugin is corrupted.";
        alert.informativeText = @"If you built the plugin from sources using Xcode, make sure to perform “Clean Build Folder“ in Xcode and then build the plugin again.\n\nIf you installed the plugin via Alctraz, there is a pending issue causing some files to be missing in the plugin. Prefer to install it via the plugin webpage.";
        [alert addButtonWithTitle:@"Download Latest"];
        [alert addButtonWithTitle:@"Cancel"];
        NSModalResponse result = [alert runModal];
        
        if (result == NSAlertFirstButtonReturn) {
            [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/CharsDavy/MethodStyleChangePlugin-Xcode"]];
        }
    }
}

@end
