%hook GMSVectorTile

- (BOOL)canOfflineWithClientParameters:(id)arg
{
    return YES;
}

- (BOOL)hasNotOfflineableRegion
{
    return NO;
}

- (BOOL)hasOfflineableRegion
{
    return YES;
}

%end
