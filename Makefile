## ROOTLESS=1 or ROOTHIDE=1 can be supplied to the make command to build a rootless or roothide package.
ifeq ($(ROOTLESS),1)
THEOS_PACKAGE_SCHEME=rootless
else ifeq ($(ROOTHIDE),1)
THEOS_PACKAGE_SCHEME=roothide
endif

DEBUG = 0
FINALPACKAGE = 1
ARCHS = arm64
TARGET := iphone:clang:16.5:13.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = YouTubeExtended
$(TWEAK_NAME)_FRAMEWORKS = UIKit Foundation SystemConfiguration
$(TWEAK_NAME)_FILES = Tweak.x
$(TWEAK_NAME)_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
