TARGET = iphone:clang:11.2:9.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AutoVPN
AutoVPN_CFLAGS = -fobjc-arc
AutoVPN_LIBRARIES = sparkapplist
AutoVPN_FILES = Tweak.x

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += ../bundle
include $(THEOS_MAKE_PATH)/aggregate.mk
