#define kPrefIdentifier @"com.linusyang.autovpn"
#define kPrefKeyConnect @"connectApps"
#define kPrefKeyDisconnect @"disconnectApps"
#define kPrefKeyEnabled @"enabled"
#define kPrefKeyForeground @"foreground"
#define kPrefKeyKeep @"keep"
#define kPrefNotification @"com.linusyang.autovpn.prefschanged"
#define kPrefBackupDir @"/var/mobile/Library/Preferences/com.linusyang.autovpn"
#define kPrefBundlePath @"/Library/PreferenceBundles/AutoVPN.bundle"
#define TRANS(s) ([[NSBundle bundleWithPath:kPrefBundlePath] localizedStringForKey:(s) value:(s) table:@"Root"])

#define AVPDEBUG 0
#if AVPDEBUG
#define LOG(...) NSLog(@"autovpn: " __VA_ARGS__)
#else
#define LOG(...)
#endif
