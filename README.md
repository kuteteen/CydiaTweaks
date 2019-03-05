My Cydia Tweaks
======

This is a collection of my Cydia Substrate tweaks. Tested with iOS 11+.

# Installation
* Add [repo.linusyang.com](https://repo.linusyang.com/) to Cydia
* Search the tweak and install.

# Tweak List

### AutoVPN
Connect/disconnect to VPN automatically in selected apps. Support to backup app lists. Similar to [SmartVPN][sv], but fewer bugs, ad-free and open-source.

### CCVPN
A VPN toggle in Control Center for iOS 11+. Similar to [CCVPN][cv], but more reliable in iOS 11+.

### HomeGesture
A fork of [HomeGesture][hg] with no configurable options. Similar to [HomeGuesture Lite][hgl], where all options are pre-defined.

### NoSimAlert
Remove "No Sim Card Installed" alert on iOS 12. Previous [tweaks][coysim] do not work on iOS 12.

### ForceChinese
Force Mi Fit app to show in Chinese language. It only works with Mi Fit app. Try to edit "ForceChinese.plist" to work with other apps.

This tweak writes language settings to the app preferences. If you want to revert to system language, try:

1. Uninstall ForceChinese
2. Install UnforceChinese
3. Open the app to activate the language change
4. Uninstall UnforceChinese

# Build
Install [theos][theos] and type `make`. Use `make -j4` to speed up the build in parallel.

# License
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

All source code is licensed under [GPLv3](http://www.gnu.org/copyleft/gpl.html).

[hg]: https://repo.dynastic.co/depiction/94936559895183360/
[sv]: http://cydia.saurik.com/package/com.zyb.smartvpn/
[cv]: http://cydia.saurik.com/package/com.kingpuffdaddi.control-center.ccvpn/
[hgl]: https://repo.packix.com/package/com.vitataf.homegesturelite/
[theos]: https://github.com/theos/theos
[coysim]: http://cydia.saurik.com/package/com.cydiageek.coysim/
