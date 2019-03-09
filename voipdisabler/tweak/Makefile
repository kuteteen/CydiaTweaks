TARGET = iphone:clang:11.2:9.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = VOIPDisabler
VOIPDisabler_CFLAGS = -fobjc-arc
VOIPDisabler_LIBRARIES = sparkapplist
VOIPDisabler_FILES = Tweak.x

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += ../bundle
include $(THEOS_MAKE_PATH)/aggregate.mk
