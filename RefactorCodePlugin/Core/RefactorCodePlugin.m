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

@interface RefactorCodePlugin()<DZOperateDelegate>

@property (nonatomic, strong, readwrite) NSBundle *bundle;
@property (nonatomic, readonly)DZOperateController *operateController;
@property (nonatomic, copy)NSString *url;
@property (nonatomic, assign)BOOL flag;

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
        _operateController.delegate = self;
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
        menuItem = [[NSMenuItem alloc] initWithTitle:@"Refactor Method Style" action:@selector(refactorMethodStyleMenuAction) keyEquivalent:@""];
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
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Actions

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
    NSMutableAttributedString *mutableAttrString = [[NSMutableAttributedString alloc] initWithString:@"Letterpress" attributes:attrsDict];
    NSAttributedString *appendAttrString = [[NSAttributedString alloc] initWithString:string];
    [mutableAttrString appendAttributedString:appendAttrString];
    [self.operateController.preview.textStorage setAttributedString:mutableAttrString];
    [self.operateController.preview.textStorage endEditing];
}

#pragma mark - DZOperateDelegate

- (void)operateSetterStyleAction
{
    
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
    NSString *select = self.operateController.selectedTextField.stringValue;
    NSArray *array = [DZOperateCharacter findAllSpecityContentWithFilePath:self.url pattern:pattern];
    NSMutableString *preview = [NSMutableString string];
    for (NSString *findStr in array) {
        [preview appendFormat:@"\n%@", findStr];
    }

    [self updatePreviewContentWithString:preview];
    DZLog(@"findSpecifyStringWithPattern: in plugin, select string is : %@", select);
}

- (void)findSpecifyStringWithPattern:(NSString *)pattern
{
    NSString *select = self.operateController.selectedTextField.stringValue;
    NSString *findStr = [DZOperateCharacter findSpecityContentWithFilePath:self.url pattern:pattern];
    
    [self updatePreviewContentWithString:[NSString stringWithFormat:@"\n%@", findStr]];
    DZLog(@"findSpecifyStringWithPattern: in plugin, select string is : %@", select);
}

#pragma mark - Test

- (void)test
{
    [self setUrl:@"/Users/chars/Xcode_code/RefactorCodePlugin/RefactorCodePlugin/Core/RefactorCodePlugin.m"];
    [self setFlag:YES];
    NSArray *array = [NSArray arrayWithObjects:@"1", @"2", @"3", nil];
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
