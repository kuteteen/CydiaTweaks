TARGET = iphone:clang:11.2:9.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = AutoVPN
AutoVPN_FILES = AVPRootListController.m
AutoVPN_CFLAGS = -fobjc-arc
AutoVPN_LIBRARIES = sparkapplist
AutoVPN_INSTALL_PATH = /Library/PreferenceBundles
AutoVPN_FRAMEWORKS = UIKit
AutoVPN_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/AutoVPN.plist$(ECHO_END)
