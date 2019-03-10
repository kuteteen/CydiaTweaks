@interface PSSpecifier
- (NSString *)identifier;
- (void)setProperty:(id)arg1 forKey:(id)arg2;
@end

%hook PSUIGeneralController

- (id)specifiers
{
    NSArray *specs = %orig;
    for (PSSpecifier *spec in specs) {
        if ([[spec identifier] isEqualToString:@"SOFTWARE_UPDATE_LINK"]) {
            [spec setProperty:@NO forKey:@"enabled"];
            break;
        }
    }
    return specs;
}

%end

%hook PSUIResetPrefController

- (id)specifiers
{
    NSArray *specs = %orig;
    int disabled = 0;
    for (PSSpecifier *spec in specs) {
        NSString *name = [spec identifier];
        if ([name isEqualToString:@"settingsErase"] ||
            [name isEqualToString:@"fullErase"]) {
            [spec setProperty:@NO forKey:@"enabled"];
            disabled++;
        }
        if (disabled == 2) {
            break;
        }
    }
    return specs;
}

%end
