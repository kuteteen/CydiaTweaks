TARGET = iphone:clang:11.2:9.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = VOIPDisabler
VOIPDisabler_FILES = VPDRootListController.m
VOIPDisabler_CFLAGS = -fobjc-arc
VOIPDisabler_LIBRARIES = sparkapplist
VOIPDisabler_INSTALL_PATH = /Library/PreferenceBundles
VOIPDisabler_FRAMEWORKS = UIKit
VOIPDisabler_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/VOIPDisabler.plist$(ECHO_END)
