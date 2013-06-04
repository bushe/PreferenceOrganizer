ARCH = armv7
THEOS_DEVICE_IP = 150.89.227.62
TARGET = iphone:clang::5.0

include theos/makefiles/common.mk

TWEAK_NAME = PreferenceOrganizer
PreferenceOrganizer_FILES = Tweak.xm
PreferenceOrganizer_FRAMEWORKS = UIKit Foundation
PreferenceOrganizer_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/tweak.mk

BUNDLE_NAME = PreferenceOrganizerSettings
PreferenceOrganizerSettings_FILES = Preference.m
PreferenceOrganizerSettings_INSTALL_PATH = /Library/PreferenceBundles
PreferenceOrganizerSettings_FRAMEWORKS = UIKit
PreferenceOrganizerSettings_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/PreferenceOrganizer.plist$(ECHO_END)

real-clean:
	rm -rf _
	rm -rf .obj
	rm -rf obj
	rm -rf .theos
	rm -rf *.deb