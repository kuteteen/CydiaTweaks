#import <objc/runtime.h>

@interface CCUIToggleModule : NSObject
- (void)refreshState;
- (BOOL)isSelected;
- (void)setSelected:(BOOL)arg;
@end

@interface SBTelephonyManager : NSObject
+ (instancetype)sharedTelephonyManager;
- (BOOL)isUsingVPNConnection;
@end

@interface PSBundleController : NSObject
- (instancetype)initWithParentListController:(id)parentListController;
@end

@interface VPNBundleController : PSBundleController
- (void)setVPNActive:(BOOL)arg;
- (void)_setVPNActive:(BOOL)arg;
@end

@interface CCVPN : CCUIToggleModule {
    BOOL _connected;
    VPNBundleController *_controller;
    id _observer;
}
@end

@implementation CCVPN

- (id)init {
    self = [super init];
    if (self) {
        NSBundle* VPNPreferences = [NSBundle bundleWithPath:@"/System/Library/PreferenceBundles/VPNPreferences.bundle"];
        [VPNPreferences load];
        _controller = [[objc_getClass("VPNBundleController") alloc] initWithParentListController:nil];
        SBTelephonyManager *telephoneInfo = [objc_getClass("SBTelephonyManager") sharedTelephonyManager];
        _connected = telephoneInfo.isUsingVPNConnection;
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        NSOperationQueue *queue = [NSOperationQueue mainQueue];
        _observer = [center addObserverForName:@"SBVPNConnectionChangedNotification" object:nil queue:queue usingBlock:^(NSNotification *note) {
            _connected = telephoneInfo.isUsingVPNConnection;
            [self refreshState];
        }];
    }
    return self;
}

- (void)dealloc {
    if (_observer != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:_observer];
    }
}

- (UIImage *)iconGlyph {
	return [UIImage imageNamed:@"Icon" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
}

- (UIColor *)selectedColor {
	return [UIColor colorWithRed:0.0 green:111.0/255.0 blue:1.0 alpha:1.0];;
}

- (BOOL)isSelected {
    return _connected;
}

- (void)setSelected:(BOOL)arg {
    if ([_controller respondsToSelector:@selector(_setVPNActive:)]) {
        [_controller _setVPNActive:arg];
    } else if ([_controller respondsToSelector:@selector(setVPNActive:)]) {
        [_controller setVPNActive:arg];
    }
}

@end
