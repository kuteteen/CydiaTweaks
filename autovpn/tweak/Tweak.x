#import "common.h"
#import <version.h>

#define kForeground 2

@interface SBApplication : NSObject
- (NSString *)bundleIdentifier;
@end

@interface FBProcessState : NSObject
- (int)visibility;
@end

@interface VPNBundleController : NSObject
- (id)initWithParentListController:(id)arg;
- (id)vpnActiveForSpecifier:(id)arg;
- (void)setVPNActive:(BOOL)arg;
- (void)_setVPNActive:(BOOL)arg;
@end

@interface SparkAppList : NSObject
+ (BOOL)doesIdentifier:(NSString *)identifier
        andKey:(NSString *)key
        containBundleIdentifier:(NSString *)bundleIdentifier;
@end

static NSMutableSet *runningApps = nil;
static VPNBundleController *controller = nil;
static NSDictionary *prefs = nil;

#define isEnabled ([prefs[kPrefKeyEnabled] boolValue])
#define isKeep ([prefs[kPrefKeyKeep] boolValue])
#define isForeground ([prefs[kPrefKeyForeground] boolValue])

static void updateSettings() {
    CFPreferencesAppSynchronize((CFStringRef)kPrefIdentifier);
    NSArray *keyList = @[kPrefKeyEnabled, kPrefKeyForeground, kPrefKeyKeep];
    prefs = (__bridge_transfer NSDictionary *)CFPreferencesCopyMultiple((__bridge CFArrayRef)keyList, (CFStringRef)kPrefIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    LOG("settings updated: %@", prefs);
}

static void settingsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    LOG("receive settings changed event");
    updateSettings();
}

static void connectVPN(BOOL connect) {
    LOG("%@ vpn...", connect ? @"connect" : @"disconnect");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([controller respondsToSelector:@selector(_setVPNActive:)]) {
            [controller _setVPNActive:connect];
        } else if ([controller respondsToSelector:@selector(setVPNActive:)]) {
            [controller setVPNActive:connect];
        }
    });
}

static void appLaunched(NSString *identifier) {
    LOG("app launched: %@", identifier);
    if (!isEnabled) {
        return;
    }
    if ([SparkAppList doesIdentifier:kPrefIdentifier
                      andKey:kPrefKeyDisconnect
                      containBundleIdentifier:identifier]) {
        LOG("disconnect app matched");
        connectVPN(NO);
    } else if ([SparkAppList doesIdentifier:kPrefIdentifier
                             andKey:kPrefKeyConnect
                             containBundleIdentifier:identifier]) {
        LOG("connect app matched");
        connectVPN(YES);
        [runningApps addObject:identifier];
    }
}

static void appGoBackground(NSString *identifier) {
    LOG("app go background: %@", identifier);
    if (!isEnabled) {
        return;
    }
    if (isForeground &&
        [SparkAppList doesIdentifier:kPrefIdentifier
                      andKey:kPrefKeyConnect
                      containBundleIdentifier:identifier]) {
        LOG("foreground only, stop vpn for %@", identifier);
        connectVPN(NO);
    }
}

static void appExited(NSString *identifier) {
    LOG("app exited: %@", identifier);
    if (!isEnabled) {
        return;
    }
    [runningApps removeObject:identifier];
    if (!isKeep && runningApps.count == 0) {
        LOG("no running apps, stop vpn");
        connectVPN(NO);
    }
}

%hook SBApplication

%group preiOS11

- (void)willActivate {
    appLaunched([self bundleIdentifier]);
    %orig;
}

- (void)didDeactivateForEventsOnly:(bool)arg {
    appGoBackground([self bundleIdentifier]);
    %orig;
}

- (void)didExitWithContext:(id)context {
    appExited([self bundleIdentifier]);
    %orig;
}

%end

%group iOS11

- (void)_updateProcess:(id)process withState:(FBProcessState *)state {
    if ([state visibility] == kForeground) {
        appLaunched([self bundleIdentifier]);
    }
    %orig;
}

- (void)saveSnapshotForSceneHandle:(id)arg1 context:(id)arg2 completion:(id)arg3 {
    appGoBackground([self bundleIdentifier]);
    %orig;
}

- (void)_didExitWithContext:(id)context {
    appExited([self bundleIdentifier]);
    %orig;
}

%end

%end

%ctor {
    NSBundle* VPNPreferences = [NSBundle bundleWithPath:@"/System/Library/PreferenceBundles/VPNPreferences.bundle"];
    if ([VPNPreferences load]) {
        Class cls = objc_getClass("VPNBundleController");
        if (cls) {
            controller = [[cls alloc] initWithParentListController:nil];
        }
    }
    if (controller == nil) {
        LOG("failed to initialize VPN controller");
    }
    updateSettings();
    runningApps = [NSMutableSet set];
    CFNotificationCenterAddObserver(
        CFNotificationCenterGetDarwinNotifyCenter(),
        NULL,
        &settingsChanged,
        (CFStringRef)kPrefNotification,
        NULL,
        CFNotificationSuspensionBehaviorDeliverImmediately);
    if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_11_0) {
        %init(iOS11);
    } else {
        %init(preiOS11);
    }
    %init;
    LOG("initialized");
}
