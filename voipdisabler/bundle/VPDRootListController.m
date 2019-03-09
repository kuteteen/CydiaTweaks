#import <Preferences/PSListController.h>
#import "../tweak/common.h"

@interface SparkAppListTableViewController : UITableViewController
- (id)initWithIdentifier:(NSString *)identifier andKey:(NSString *)key;
@end

@interface VPDRootListController : PSListController
@end

@implementation VPDRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    }
	return _specifiers;
}

- (void)selectApps {
    SparkAppListTableViewController *vc = [[SparkAppListTableViewController alloc] initWithIdentifier:kPrefIdentifier andKey:kPrefKeyApps];
    [self.navigationController pushViewController:vc animated:YES];
    self.navigationItem.hidesBackButton = FALSE;
}

- (void)respring {
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)kRespringNotification, NULL, NULL, true);
}

@end
