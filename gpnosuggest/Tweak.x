%hook SKTContactsDataManager

- (id)loadContactsWithQueryText:(id)arg1 forceQuery:(_Bool)arg2 forUIType:(long long)arg3
{
    return nil;
}

- (id)loadSuggestedContactsForUIType:(long long)arg1
{
    return nil;
}

- (id)selectedContacts
{
    return nil;
}

- (id)suggestedContacts
{
    return nil;
}

%end
