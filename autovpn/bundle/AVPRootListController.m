#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import "../tweak/common.h"

@interface SparkAppListTableViewController : UITableViewController
- (id)initWithIdentifier:(NSString *)identifier andKey:(NSString *)key;
@end

@interface SparkAppList : NSObject
+ (NSArray *)getAppListForIdentifier:(NSString *)identifier andKey:(NSString *)key;
+ (void)setAppList:(NSArray *)appList forIdentifier:(NSString *)identifier andKey:(NSString *)key;
@end

static NSDictionary *loadPrefs() {
    NSDictionary *prefs = nil;
    CFPreferencesSynchronize((CFStringRef)kPrefIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    NSArray *keyList = @[kPrefKeyEnabled, kPrefKeyForeground, kPrefKeyKeep];
    prefs = (__bridge_transfer NSDictionary *)CFPreferencesCopyMultiple((__bridge CFArrayRef)keyList, (CFStringRef)kPrefIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    NSMutableDictionary *allPrefs = [NSMutableDictionary dictionaryWithDictionary:prefs];
    allPrefs[kPrefKeyConnect] = [SparkAppList getAppListForIdentifier:kPrefIdentifier andKey:kPrefKeyConnect];
    allPrefs[kPrefKeyDisconnect] = [SparkAppList getAppListForIdentifier:kPrefIdentifier andKey:kPrefKeyDisconnect];
    return allPrefs;
}

#define ARRVALUE(x) ((x) == nil ? [NSArray array] : (x))
#define BOOLVALUE(x) (@([x boolValue]))
#define SAVE(p, q, k, t) (p[k] = t ## VALUE(q[k]))

static BOOL savePrefs(NSDictionary *prefs) {
    NSMutableDictionary *savePrefs = [NSMutableDictionary dictionary];
    SAVE(savePrefs, prefs, kPrefKeyEnabled, BOOL);
    SAVE(savePrefs, prefs, kPrefKeyForeground, BOOL);
    SAVE(savePrefs, prefs, kPrefKeyKeep, BOOL);
    SAVE(savePrefs, prefs, kPrefKeyConnect, ARR);
    SAVE(savePrefs, prefs, kPrefKeyDisconnect, ARR);
    CFPreferencesSetMultiple((__bridge CFDictionaryRef)savePrefs, NULL, (CFStringRef)kPrefIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    [SparkAppList setAppList:savePrefs[kPrefKeyConnect] forIdentifier:kPrefIdentifier andKey:kPrefKeyConnect];
    [SparkAppList setAppList:savePrefs[kPrefKeyDisconnect] forIdentifier:kPrefIdentifier andKey:kPrefKeyDisconnect];
    return CFPreferencesSynchronize((CFStringRef)kPrefIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
}

static BOOL saveBackup(NSDictionary *prefs, NSString *name) {
    NSString *bakName = [[name stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceAndNewlineCharacterSet]] lastPathComponent];
    if (bakName.length == 0) {
        LOG("saving backup: empty backup name");
        return NO;
    }
    if (prefs.count == 0) {
        LOG("saving backup: empty prefs");
        return NO;
    }
    BOOL isDir = NO;
    BOOL pathExists = [[NSFileManager defaultManager] fileExistsAtPath:kPrefBackupDir isDirectory:&isDir];
    if (pathExists && !isDir) {
        if (![[NSFileManager defaultManager] removeItemAtPath:kPrefBackupDir error:nil]) {
            LOG("failed to remove %@", kPrefBackupDir);
            return NO;
        }
        pathExists = NO;
    }
    if (!pathExists) {
        if (![[NSFileManager defaultManager] createDirectoryAtPath:kPrefBackupDir withIntermediateDirectories:NO attributes:nil error:nil]) {
            LOG("failed to create dir: %@", kPrefBackupDir);
            return NO;
        }
    }

    BOOL ret = [prefs writeToFile:[NSString stringWithFormat:@"%@/%@.bak", kPrefBackupDir, bakName] atomically:YES];
    LOG("backup '%@' saved %@: %@", name, ret ? @"successfully" : @"badly!", prefs);
    return ret;
}

static BOOL removeBackup(NSString *name) {
    NSString *bakName = [[name stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceAndNewlineCharacterSet]] lastPathComponent];
    NSString *path = [NSString stringWithFormat:@"%@/%@.bak", kPrefBackupDir, bakName];
    BOOL ret = [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    LOG("backup '%@' removed %@", name, ret ? @"successfully" : @"badly!");
    return ret;
}

static NSArray *backupList() {
    NSArray *fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:kPrefBackupDir error:nil];
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:[fileList count]];
    [fileList enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        [ret addObject:[obj stringByDeletingPathExtension]];
    }];
    NSArray *result = [ret sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    return result;
}

static BOOL restoreBackup(NSString *name) {
    if (name.length == 0) {
        LOG("cannot restore empty backup");
        return NO;
    }
    NSString *bakName = [[name stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceAndNewlineCharacterSet]] lastPathComponent];
    NSString *path = [NSString stringWithFormat:@"%@/%@.bak", kPrefBackupDir, bakName];
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:path];
    BOOL ret = savePrefs(prefs);
    LOG("backup '%@' restored %@: %@", name, ret ? @"successfully" : @"badly!", prefs);
    return ret;
}

@interface PSEditableListController : PSListController
@end

@interface AVPRootListController : PSListController
@end

@interface AVPListController : PSEditableListController
@end

@implementation AVPListController
- (id)specifiers {
    if (!_specifiers) {
        NSArray *list = backupList();
        _specifiers = [NSMutableArray array];
        PSSpecifier *group = [PSSpecifier preferenceSpecifierNamed:@"Backup Files"
                                          target:self
                                             set:NULL
                                             get:NULL
                                          detail:Nil
                                            cell:PSGroupCell
                                            edit:Nil];
        [group setProperty:@"Backup Files" forKey:@"label"];
        if (list.count == 0) {
            [group setProperty:@"Backup configurations will show up here." forKey:@"footerText"];
        }
        [_specifiers addObject:group];
        for (int i = 0; i < list.count; i++) {
            PSSpecifier* spec = [PSSpecifier preferenceSpecifierNamed:list[i]
                                             target:self
                                                set:NULL
                                                get:NULL
                                             detail:Nil
                                               cell:PSListItemCell
                                               edit:Nil];
            [spec setProperty:NSStringFromSelector(@selector(removedSpecifier:)) forKey:PSDeletionActionKey];
            [_specifiers addObject:spec];
        }
    }
    return _specifiers;
}

- (void)removedSpecifier:(PSSpecifier *)specifier{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        removeBackup(specifier.name);
    });
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PSTableCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (restoreBackup(cell.specifier.name)) {
            CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)kPrefNotification, NULL, NULL, true);
            dispatch_async(dispatch_get_main_queue(), ^(){
                NSArray *vcs = self.navigationController.viewControllers;
                if (vcs.count - 2 >= 0) {
                    AVPRootListController *lc = [vcs objectAtIndex:vcs.count - 2];
                    [lc reload];
                }
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self.navigationController popViewControllerAnimated:YES];
        });
    });
}
@end

@implementation AVPRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    }
	return _specifiers;
}

- (void)selectConnectApps {
    SparkAppListTableViewController *vc = [[SparkAppListTableViewController alloc] initWithIdentifier:kPrefIdentifier andKey:kPrefKeyConnect];
    [self.navigationController pushViewController:vc animated:YES];
    self.navigationItem.hidesBackButton = FALSE;
}

- (void)selectDisconnectApps {
    SparkAppListTableViewController *vc = [[SparkAppListTableViewController alloc] initWithIdentifier:kPrefIdentifier andKey:kPrefKeyDisconnect];
    [self.navigationController pushViewController:vc animated:YES];
    self.navigationItem.hidesBackButton = FALSE;
}

- (void)backup {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Backup Name" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
        textField.placeholder = [formatter stringFromDate:[NSDate date]];
    }];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Backup" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField = [alertController textFields][0];
        NSString *name = textField.text;
        if (name.length == 0) {
            name = textField.placeholder;
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            saveBackup(loadPrefs(), name);
        });
    }];
    [alertController addAction:confirmAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)resetAppList {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Reset App Lists" message:@"Confirm to deselect all apps in lists?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Reset" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [SparkAppList setAppList:[NSArray array] forIdentifier:kPrefIdentifier andKey:kPrefKeyConnect];
            [SparkAppList setAppList:[NSArray array] forIdentifier:kPrefIdentifier andKey:kPrefKeyDisconnect];
        });
    }];
    [alertController addAction:confirmAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
