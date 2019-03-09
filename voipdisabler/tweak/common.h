#define kPrefIdentifier @"com.linusyang.voipdisabler"
#define kPrefKeyApps @"apps"
#define kPrefKeyEnabled @"enabled"
#define kPrefNotification @"com.linusyang.voipdisabler.prefschanged"
#define kRespringNotification @"com.linusyang.voipdisabler.respring"
#define kPrefBundlePath @"/Library/PreferenceBundles/VOIPDisabler.bundle"
#define TRANS(s) ([[NSBundle bundleWithPath:kPrefBundlePath] localizedStringForKey:(s) value:(s) table:@"Root"])

#define TWEAKDEBUG 0
#if TWEAKDEBUG
#define LOG(...) NSLog(@"voipdisabler: " __VA_ARGS__)
#else
#define LOG(...)
#endif
