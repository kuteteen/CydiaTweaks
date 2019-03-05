%ctor {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"AppleLanguages"];
}
