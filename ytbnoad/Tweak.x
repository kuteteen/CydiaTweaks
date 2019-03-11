// Allow background play
%hook YTBackgroundabilityPolicy
- (BOOL)isBackgroundableByUserSettings
{
    return YES;
}
%end

%hook YTIPlayabilityStatus
- (BOOL)playableInBackground
{
    return YES;
}

- (BOOL)playableOffline
{
    return YES;
}

- (BOOL)hasPlayableInBackground
{
    return YES;
}

- (BOOL)isPlayableInBackground
{
    return YES;
}

- (BOOL)hasBackgroundability
{
    return YES;
}

- (BOOL)hasOfflineability
{
    return YES;
}
%end

%hook YTPlayerStatus
- (BOOL)backgroundPlayback
{
    return YES;
}
%end

%hook YTMutablePlayerStatus
- (BOOL)backgroundPlayback
{
    return YES;
}

- (void)setBackgroundPlayback:(BOOL)arg
{
    arg = YES;
    %orig;
}
%end

%hook MLAVPlayer
- (BOOL)backgroundPlaybackAllowed
{
    return YES;
}

- (void)setBackgroundPlaybackAllowed:(BOOL)arg
{
    arg = YES;
    %orig;
}
%end

%hook MLPlayer
- (BOOL)backgroundPlaybackAllowed
{
    return YES;
}

- (void)setBackgroundPlaybackAllowed:(BOOL)arg
{
    arg = YES;
    %orig;
}
%end

// Age restriction
%hook YTVideo
- (BOOL)isAdultContent
{
    return NO;
}
%end

// Disable upgrades
%hook YTGlobalConfig
- (BOOL)shouldShowUpgrade
{
    return NO;
}

- (BOOL)shouldShowUpgradeDialog
{
    return NO;
}
%end

// Allow HD on cellular
%hook YTVideoQualitySwitchController
- (void)setAllowAudioOnlyManualQualitySelection:(BOOL)arg
{
    arg = YES;
    %orig;
}
%end

// Remove watermark
%hook YTAnnotationsViewController
- (void)setWatermarkImage:(id)image height:(int)height
{
    image = nil;
    height = 0;
    %orig;
}
%end
