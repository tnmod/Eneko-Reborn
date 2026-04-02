TWEAK_NAME = Eneko
Eneko_FILES = EnekoGlobals.m Helpers/EnekoHelpers.m Hooks/EnekoScreenHooks.m \
              Hooks/EnekoLifecycleHooks.m Hooks/EnekoSystemHooks.m \
              EnekoPreferences.m EnekoInit.m
Eneko_CFLAGS = -fobjc-arc -DTHEOS_LEAN_AND_MEAN
Eneko_FRAMEWORKS = UIKit AVFoundation CoreMotion
Eneko_LIBRARIES = gcuniversal

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
