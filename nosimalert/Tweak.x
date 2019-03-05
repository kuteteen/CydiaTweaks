@interface SBUserNotificationAlert : NSObject
- (NSString *)alertHeader;
@end

@interface SBAlertItemsController
-(void)deactivateAlertItem:(id)arg;
@end

%hook SBAlertItemsController

- (void)activateAlertItem:(id)item
{
    if ([item isKindOfClass:[%c(SBUserNotificationAlert) class]]) {
        SBUserNotificationAlert *alert = (SBUserNotificationAlert *)item;
        NSBundle *bundle = [NSBundle bundleWithPath:@"/System/Library/Frameworks/CoreTelephony.framework"];
        NSString *title = [bundle localizedStringForKey:@"NO_SIM_CARD_INSTALLED"
            value:@"No SIM Card Installed" table:@"CBMessage"];
        if ([[alert alertHeader] isEqualToString:title]) {
            [self deactivateAlertItem:item];
            return;
        }
    }
    %orig;
}

%end
