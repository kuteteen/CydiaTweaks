include $(THEOS)/makefiles/common.mk

export TARGET = iphone:clang:11.2:11.0
export ARCHS = arm64

BUNDLE_NAME = CCVPN
CCVPN_BUNDLE_EXTENSION = bundle
CCVPN_FILES = CCVPN.m
CCVPN_CFLAGS = -fobjc-arc
CCVPN_PRIVATE_FRAMEWORKS = ControlCenterUIKit
CCVPN_INSTALL_PATH = /Library/ControlCenter/Bundles/

include $(THEOS_MAKE_PATH)/bundle.mk
