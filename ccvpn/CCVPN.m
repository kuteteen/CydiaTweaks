#import <objc/runtime.h>

@interface CCUIToggleModule : NSObject
-(void)refreshState;
@end

@interface VPNBundleController : NSObject

- (id)initWithParentListController:(id)arg;
- (id)vpnActiveForSpecifier:(id)arg;
- (void)setVPNActive:(BOOL)arg;
- (void)_setVPNActive:(BOOL)arg;

@end

@interface CCVPN : CCUIToggleModule
@property (nonatomic, strong) VPNBundleController *ctrl;
@end

static void VPNSettingsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    [(CCVPN *)observer refreshState];
}

@implementation CCVPN

- (CCVPN *)init {
    self = [super init];

    if (self) {
        NSBundle* VPNPreferences = [NSBundle bundleWithPath:@"/System/Library/PreferenceBundles/VPNPreferences.bundle"];
        if ([VPNPreferences load]) {
            Class cls = objc_getClass("VPNBundleController");
            if (cls) {
                self.ctrl = [[cls alloc] initWithParentListController:nil];
                CFNotificationCenterRef center = CFNotificationCenterGetLocalCenter();
                CFNotificationCenterAddObserver(center, self, VPNSettingsChanged, CFSTR("SBVPNConnectionChangedNotification"), NULL, CFNotificationSuspensionBehaviorCoalesce);
            }
        }
    }
    
    return self;
}

- (UIImage *)iconGlyph {
	return [UIImage imageNamed:@"Icon" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
}

- (UIColor *)selectedColor {
	return [UIColor blueColor];
}

- (BOOL)isSelected {
    id specifier = [self.ctrl valueForKey:@"_vpnSpecifier"];
    return [[self.ctrl vpnActiveForSpecifier:specifier] boolValue];
}

- (void)setSelected:(BOOL)selected {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([self.ctrl respondsToSelector:@selector(_setVPNActive:)]) {
            [self.ctrl _setVPNActive:selected];
        } else if ([self.ctrl respondsToSelector:@selector(setVPNActive:)]) {
            [self.ctrl setVPNActive:selected];
        }
    });
}

@end
