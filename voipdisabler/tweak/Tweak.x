#import "common.h"
#import <version.h>

@interface SBApplication : NSObject
- (NSString *)bundleIdentifier;
@end

@interface SBApplicationInfo : NSObject
- (NSString *)bundleIdentifier;
- (BOOL)supportsBackgroundMode:(NSString *)mode;
@end

@interface FBSystemService : NSObject
+ (id)sharedInstance;
- (void)exitAndRelaunch:(BOOL)arg;
@end

@interface SparkAppList : NSObject
+ (BOOL)doesIdentifier:(NSString *)identifier
        andKey:(NSString *)key
        containBundleIdentifier:(NSString *)bundleIdentifier;
+ (NSArray *)getAppListForIdentifier:(NSString *)identifier andKey:(NSString *)key;
@end

static NSDictionary *prefs = nil;
#define isEnabled() ([prefs[kPrefKeyEnabled] boolValue])
#define matchApp(i) ([SparkAppList doesIdentifier:kPrefIdentifier \
                                   andKey:kPrefKeyApps \
                                   containBundleIdentifier:i])

static void updateSettings() {
    CFPreferencesAppSynchronize((CFStringRef)kPrefIdentifier);
    NSArray *keyList = @[kPrefKeyEnabled];
    prefs = (__bridge_transfer NSDictionary *)CFPreferencesCopyMultiple((__bridge CFArrayRef)keyList, (CFStringRef)kPrefIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    LOG("settings updated: %@", prefs);
    LOG("app list: %@", [SparkAppList getAppListForIdentifier:kPrefIdentifier andKey:kPrefKeyApps]);
}

static void __attribute__((unused)) settingsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    LOG("receive settings changed event");
    updateSettings();
}

static void respringReceived(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    LOG("receive respring event");
    [[%c(FBSystemService) sharedInstance] exitAndRelaunch:YES];
}

static void removeVOIP(SBApplicationInfo *info)
{
    if (!isEnabled()) {
        return;
    }
    if (info == nil || ![info isKindOfClass:[%c(SBApplicationInfo) class]]) {
        LOG("mismatched info class");
        return;
    }
    NSString *identifier = [info bundleIdentifier];
    if (!matchApp(identifier)) {
        return;
    }
    LOG("app identifier: %@", identifier);
    LOG("voip mode (before): %@", [info supportsBackgroundMode:@"voip"] ? @"yes" : @"no");
    Ivar ivar = class_getInstanceVariable(object_getClass(info), "_backgroundModes");
    if (ivar == NULL) {
        LOG("ivar not found");
        return;
    }
    NSSet *modes = object_getIvar(info, ivar);
    LOG("all background modes: %@", modes);
    if ([modes containsObject:@"voip"]) {
        NSMutableSet *mutableSet = [modes mutableCopy];
        [mutableSet removeObject:@"voip"];
        NSSet *newSet = [mutableSet copy];
        object_setIvar(info, ivar, newSet);
        LOG("voip mode (after): %@", [info supportsBackgroundMode:@"voip"] ? @"yes" : @"no");
    }
}

static BOOL enabledVOIP(NSString *identifier)
{
    if (isEnabled() && matchApp(identifier)) {
        return NO;
    }
    return YES;
}

%hook SBApplication

- (id)initWithApplicationInfo:(SBApplicationInfo *)info
{
    removeVOIP(info);
    return %orig;
}

%group iOS12
-(void)setInfo:(SBApplicationInfo *)info
{
    removeVOIP(info);
    %orig;
}
%end

%group iOS11
- (BOOL)wantsAutoLaunchForVOIP
{
    BOOL ret = %orig;
    if (ret) {
        BOOL override = enabledVOIP([self bundleIdentifier]);
        if (!override) {
            LOG("disable voip auto launch: %@", [self bundleIdentifier]);
        }
        ret = override;
    }
    return ret;
}
%end

%group preiOS11
- (BOOL)_shouldAutoLaunchForVoIP
{
    BOOL ret = %orig;
    if (ret) {
        BOOL override = enabledVOIP([self bundleIdentifier]);
        if (!override) {
            LOG("disable voip auto launch: %@", [self bundleIdentifier]);
        }
        ret = override;
    }
    return ret;
}
%end

%end

%ctor {
    updateSettings();
    /*
    CFNotificationCenterAddObserver(
        CFNotificationCenterGetDarwinNotifyCenter(),
        NULL,
        &settingsChanged,
        (CFStringRef)kPrefNotification,
        NULL,
        CFNotificationSuspensionBehaviorDeliverImmediately);
    */
    CFNotificationCenterAddObserver(
        CFNotificationCenterGetDarwinNotifyCenter(),
        NULL,
        &respringReceived,
        (CFStringRef)kRespringNotification,
        NULL,
        CFNotificationSuspensionBehaviorDeliverImmediately);
    if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_11_0) {
        %init(iOS11);
    } else {
        %init(preiOS11);
    }
    if (kCFCoreFoundationVersionNumber >= 1535.12) {
        %init(iOS12);
    }
    %init;
    LOG("initialized");
}
