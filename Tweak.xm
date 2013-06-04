//
//  PreferenceOrganizer.mm
//  PreferenceOrganizer
//
//  Created by Qusic on 4/19/13.
//  Copyright (c) 2013 Qusic. All rights reserved.
//

// CaptainHook by Ryan Petrich
// see https://github.com/rpetrich/CaptainHook/

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Preferences/Preferences.h>
#import "CaptainHook/CaptainHook.h"

#ifndef kCFCoreFoundationVersionNumber_iOS_5_0
#define kCFCoreFoundationVersionNumber_iOS_5_0 675.00
#endif

#ifndef kCFCoreFoundationVersionNumber_iOS_6_0
#define kCFCoreFoundationVersionNumber_iOS_6_0 793.00
#endif

#define PREF_PATH @"/var/mobile/Library/Preferences/me.qusic.preferenceorganizer.plist"

// Objective-C runtime hooking using CaptainHook:
//   1. declare class using CHDeclareClass()
//   2. load class using CHLoadClass() or CHLoadLateClass() in CHConstructor
//   3. hook method using CHOptimizedMethod()
//   4. register hook using CHHook() in CHConstructor
//   5. (optionally) call old method using CHSuper()

static NSMutableArray *GeneralSpecifiers;
static NSMutableArray *CydiaSpecifiers;
static NSMutableArray *AppStoreSpecifiers;
static BOOL isGeneralEnabled;
static BOOL isCydiaEnabled;
static BOOL isAppStoreEnabled;
static NSInteger g_group = 1;

@interface UIImage (Private)
+(UIImage *)_applicationIconImageForBundleIdentifier:(NSString *)bundleIdentifier format:(int)format scale:(CGFloat)scale;
@end

@interface GeneralsSpecifiersController : PSListController
@end
@implementation GeneralsSpecifiersController
- (void)setupPhoneSpecifier:(id)arg1 {}
- (void)phoneItemString:(id)arg1 {}
- (void)length {}
- (NSArray *)specifiers
{
    if (_specifiers == nil) { self.specifiers = GeneralSpecifiers; }
    return _specifiers;
}
@end

@interface CydiaSpecifiersController : PSListController
@end
@implementation CydiaSpecifiersController
- (NSArray *)specifiers
{
    if (_specifiers == nil) { self.specifiers = CydiaSpecifiers; }
    return _specifiers;
}
@end

@interface AppStoreSpecifiersController : PSListController
@end
@implementation AppStoreSpecifiersController
- (NSArray *)specifiers
{
    if (_specifiers == nil) { self.specifiers = AppStoreSpecifiers; }
    return _specifiers;
}
@end

CHDeclareClass(PrefsListController)
CHOptimizedMethod(0, self, NSMutableArray *, PrefsListController, specifiers)
{
    NSMutableArray *specifiers = CHSuper(0, PrefsListController, specifiers);
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableDictionary *savedSpecifiers = [NSMutableDictionary dictionary];
        NSInteger group = -1;
        for (PSSpecifier *s in specifiers) {
            if (s->cellType == 0) {
                group++;
                if (group >= g_group) {
                    [savedSpecifiers setObject:[NSMutableArray array] forKey:[NSNumber numberWithInteger:group]];
                } else {
                    continue;
                }
            }
            if (group >= g_group) {
                [[savedSpecifiers objectForKey:[NSNumber numberWithInteger:group]] addObject:s];
            }
        }
        AppStoreSpecifiers = [[savedSpecifiers objectForKey:[NSNumber numberWithInteger:group]] retain];
        if ([[[[savedSpecifiers objectForKey:[NSNumber numberWithInteger:group-1]] objectAtIndex:1] identifier]isEqualToString:@"DEVELOPER_SETTINGS"] && kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_6_0) {
            CydiaSpecifiers = [[savedSpecifiers objectForKey:[NSNumber numberWithInteger:group-2]] retain];
            GeneralSpecifiers = [[savedSpecifiers objectForKey:[NSNumber numberWithInteger:group-6]] retain];
            [GeneralSpecifiers addObjectsFromArray:[savedSpecifiers objectForKey:[NSNumber numberWithInteger:group-5]]];
            [GeneralSpecifiers addObjectsFromArray:[savedSpecifiers objectForKey:[NSNumber numberWithInteger:group-4]]];
            [GeneralSpecifiers addObjectsFromArray:[savedSpecifiers objectForKey:[NSNumber numberWithInteger:group-3]]];
        } else {
            CydiaSpecifiers = [[savedSpecifiers objectForKey:[NSNumber numberWithInteger:group-1]] retain];
            if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_6_0) {
                GeneralSpecifiers = [[savedSpecifiers objectForKey:[NSNumber numberWithInteger:group-5]] retain];
                [GeneralSpecifiers addObjectsFromArray:[savedSpecifiers objectForKey:[NSNumber numberWithInteger:group-4]]];
                [GeneralSpecifiers addObjectsFromArray:[savedSpecifiers objectForKey:[NSNumber numberWithInteger:group-3]]];
                [GeneralSpecifiers addObjectsFromArray:[savedSpecifiers objectForKey:[NSNumber numberWithInteger:group-2]]];
            } else {
                GeneralSpecifiers = [[savedSpecifiers objectForKey:[NSNumber numberWithInteger:group-2]] retain];
            }
        }
        
        [specifiers addObject:[PSSpecifier groupSpecifierWithName:nil]];
        if (isGeneralEnabled && GeneralSpecifiers.count > 0) {
            [specifiers removeObjectsInArray:GeneralSpecifiers];
            [GeneralSpecifiers removeObjectAtIndex:0];
            PSSpecifier *generalSpecifier = [PSSpecifier preferenceSpecifierNamed:@"General " target:self set:NULL get:NULL
                                                                         detail:[GeneralsSpecifiersController class]
                                                                           cell:[PSTableCell cellTypeFromString:@"PSLinkCell"] edit:Nil];
            [generalSpecifier setProperty:[UIImage _applicationIconImageForBundleIdentifier:@"com.apple.Preferences" format:0 scale:[UIScreen mainScreen].scale] forKey:@"iconImage"];
            [specifiers addObject:generalSpecifier];
        }
        if (isCydiaEnabled && CydiaSpecifiers.count > 0) {
            [specifiers removeObjectsInArray:CydiaSpecifiers];
            [CydiaSpecifiers removeObjectAtIndex:0];
            PSSpecifier *cydiaSpecifier = [PSSpecifier preferenceSpecifierNamed:@"Cydia" target:self set:NULL get:NULL
                                                                         detail:[CydiaSpecifiersController class]
                                                                           cell:[PSTableCell cellTypeFromString:@"PSLinkCell"] edit:Nil];
            [cydiaSpecifier setProperty:[UIImage _applicationIconImageForBundleIdentifier:@"com.saurik.Cydia" format:0 scale:[UIScreen mainScreen].scale] forKey:@"iconImage"];
            [specifiers addObject:cydiaSpecifier];
        }
        if (isAppStoreEnabled && AppStoreSpecifiers.count > 0) {
            [specifiers removeObjectsInArray:AppStoreSpecifiers];
            [AppStoreSpecifiers removeObjectAtIndex:0];
            PSSpecifier *appstoreSpecifier = [PSSpecifier preferenceSpecifierNamed:@"App Store" target:self set:NULL get:NULL
                                                                            detail:[AppStoreSpecifiersController class]
                                                                              cell:[PSTableCell cellTypeFromString:@"PSLinkCell"] edit:Nil];
            [appstoreSpecifier setProperty:[UIImage _applicationIconImageForBundleIdentifier:@"com.apple.AppStore" format:0 scale:[UIScreen mainScreen].scale] forKey:@"iconImage"];
            [specifiers addObject:appstoreSpecifier];
        }
    });
    return specifiers;
}

CHOptimizedMethod(0, self, void, PrefsListController, refreshGeneralBundles)
{
    CHSuper(0, PrefsListController, refreshGeneralBundles);
    NSMutableArray *savedSpecifiers = [NSMutableArray array];
    BOOL go = NO;
    for (PSSpecifier *s in CHIvar(self, _specifiers, NSMutableArray *)) {
        if (!go && [s.identifier isEqualToString:@"General "]) {
            go = YES;
            continue;
        }
        if (go) {
            [savedSpecifiers addObject:s];
        }
    }
    for (PSSpecifier *s in savedSpecifiers) {
        [self removeSpecifier:s];
    }
    [savedSpecifiers removeObjectAtIndex:0];
    [GeneralSpecifiers release];
    GeneralSpecifiers = [savedSpecifiers retain];
}

CHOptimizedMethod(0, self, void, PrefsListController, refresh3rdPartyBundles)
{
    CHSuper(0, PrefsListController, refresh3rdPartyBundles);
    NSMutableArray *savedSpecifiers = [NSMutableArray array];
    BOOL go = NO;
    for (PSSpecifier *s in CHIvar(self, _specifiers, NSMutableArray *)) {
        if (!go && [s.identifier isEqualToString:@"App Store"]) {
            go = YES;
            continue;
        }
        if (go) {
            [savedSpecifiers addObject:s];
        }
    }
    for (PSSpecifier *s in savedSpecifiers) {
        [self removeSpecifier:s];
    }
    [savedSpecifiers removeObjectAtIndex:0];
    [AppStoreSpecifiers release];
    AppStoreSpecifiers = [savedSpecifiers retain];
}

static void LoadSettings()
{
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PREF_PATH];
    id generalPref = [dict objectForKey:@"isGeneralEnabled"];
    isGeneralEnabled = generalPref ? [generalPref boolValue] : YES;
    id cydiaPref = [dict objectForKey:@"isCydiaEnabled"];
    isCydiaEnabled = cydiaPref ? [cydiaPref boolValue] : YES;
    id appStorePref = [dict objectForKey:@"isAppStoreEnabled"];
    isAppStoreEnabled = appStorePref ? [appStorePref boolValue] : YES;
}

static void ChangeNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
  LoadSettings();
}

CHConstructor
{
    @autoreleasepool {
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, ChangeNotification, CFSTR("me.qusic.preferenceorganizer.preferencechanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
        LoadSettings();
        CHLoadLateClass(PrefsListController);
        CHHook(0, PrefsListController, specifiers);
        CHHook(0, PrefsListController, refreshGeneralBundles);
        CHHook(0, PrefsListController, refresh3rdPartyBundles);
    }
}