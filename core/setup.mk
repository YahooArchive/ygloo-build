ifeq ($(BUILD_ANDROID),)
ifneq ($(NDK_ROOT),)
BUILD_ANDROID:=true
endif
endif
