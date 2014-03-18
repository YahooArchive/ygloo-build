TOPDIR=$(shell pwd)/
BUILD_SYSTEM:= $(TOPDIR)build/core
BUILD_TOOLS:= $(TOPDIR)build/tools
BUILD_COMBOS:= $(BUILD_SYSTEM)/combo

CLEAR_VARS:= $(BUILD_SYSTEM)/clear_vars.mk
BUILD_SHARED_LIBRARY:= $(BUILD_SYSTEM)/shared_library.mk
BUILD_STATIC_LIBRARY:= $(BUILD_SYSTEM)/static_library.mk
BUILD_EXECUTABLE:= $(BUILD_SYSTEM)/executable.mk

SHOW_COMMANDS:=true

BUILD_DEBUG:=false
BUILD_STRICT:=false

# These are the modifier targets that don't do anything themselves, but
# change the behavior of the build.
# (must be defined before including definitions.make)
INTERNAL_MODIFIER_TARGETS := showcommands native android ios debug release ccache clang clang-sanitize-address

# Default rule (if calling "make" with no argument)
default: all

include $(BUILD_SYSTEM)/extensions.mk
include $(BUILD_SYSTEM)/envsetup.mk

# module-built-files
# module-installed-files
# module-stubs-files


# The 'ccache' goal says to use ccache
USE_CCACHE:=$(filter ccache,$(MAKECMDGOALS))

# ccache breaks static analyzer
ifneq ($(findstring ccc-analyzer,$(CC)),)
USE_CCACHE:=
endif

# The 'clang' goal says to use clang
USE_CLANG:=$(filter clang,$(MAKECMDGOALS))
USE_CLANG_SANITIZE_ADDRESS:=$(filter clang-sanitize-address,$(MAKECMDGOALS))

# The 'showcommands' goal says to show the full command
# lines being executed, instead of a short message about
# the kind of operation being done.
SHOW_COMMANDS:=$(filter showcommands,$(MAKECMDGOALS))

# The 'native' goal says to build for local host
BUILD_TARGET_NATIVE:=$(filter native,$(MAKECMDGOALS))
ifeq ($(HOST_OS),darwin)
BUILD_TARGET_NATIVE_STATIC_LIB:=true
endif

# The 'android' goal says to build for Android (AOSP)
BUILD_TARGET_ANDROID:=$(filter android,$(MAKECMDGOALS))

# The 'ios' goal says to build for iOS
BUILD_TARGET_IOS:=$(filter ios,$(MAKECMDGOALS))

ifneq ($(filter debug,$(MAKECMDGOALS)),)
BUILD_DEBUG:=true
endif
ifneq ($(filter release,$(MAKECMDGOALS)),)
BUILD_DEBUG:=false
endif

BUILD_HOST:=false
BUILD_HOST_STATIC_LIB:=false
BUILD_ANDROID:=false
BUILD_IOS:=false

BUILD_SUPPORT_EXECUTABLE:=false
BUILD_SUPPORT_SHARED:=false

ifneq ($(BUILD_TARGET_NATIVE),)
BUILD_HOST:=true
BUILD_SUPPORT_EXECUTABLE:=true
BUILD_SUPPORT_SHARED:=true
ifneq ($(BUILD_TARGET_NATIVE_STATIC_LIB),)
BUILD_HOST_STATIC_LIB:=true
endif
include $(BUILD_SYSTEM)/compiler/native.mk
else
ifneq ($(BUILD_TARGET_IOS),)
BUILD_IOS:=true
BUILD_SUPPORT_EXECUTABLE:=false
BUILD_SUPPORT_SHARED:=false
include $(BUILD_SYSTEM)/compiler/ios.mk
else
BUILD_ANDROID:=true
BUILD_SUPPORT_EXECUTABLE:=true
ifneq ($(NDK_ROOT),)
BUILD_SUPPORT_SHARED:=true
endif
include $(BUILD_SYSTEM)/compiler/ndk.mk
endif
endif

ifneq ($(USE_CLANG),)
TARGET_COMPILER:=clang
endif

combo_target:=TARGET_
include $(BUILD_COMBOS)/select.mk

include $(BUILD_SYSTEM)/definitions.mk

TARGET_OUT_INTERMEDIATES:=$(OBJSDIR)

subdirs :=
subdirs += external
subdirs += framework
subdirs += apps

subdir_makefiles := \
        $(shell $(BUILD_TOOLS)/findleaves.py --prune=out --prune=.repo --prune=.git $(subdirs) Android.mk)

default: all

# Include all makefiles
include $(subdir_makefiles)

# Explicit rules
include $(BUILD_SYSTEM)/modules/modules.mk

# Explicit rules
include $(BUILD_SYSTEM)/modules/combo.mk

.PHONY: list
list:
	@echo $(ALL_MODULES)

all: $(EXES) $(SOLIBS) $(STATICLIBS)

combo: $(COMBOLIBS)

targetlib: $(MAINLIB)

.PHONY: clean
clean:
	@rm -rf $(OBJSDIR)

analyzer_clang=$(call ndk-clang)
scanner=$(call ndk-scan-build)

.PHONY: analyzer
analyzer:
	@make native clean
	@$(scanner) -o out/analyzer --use-analyzer=$(analyzer_clang) make all native debug -j4

.PHONY: showcommands
showcommands:
	@echo >/dev/null

.PHONY: clang
clang:
	@echo >/dev/null

.PHONY: clang-sanitize-address
clang-sanitize-address:
	@echo >/dev/null

.PHONY: ccache
ccache:
	@echo >/dev/null

.PHONY: native
native:
	@echo >/dev/null

.PHONY: android
android:
	@echo >/dev/null

.PHONY: ios
ios:
	@echo >/dev/null

.PHONY: debug
debug:
	@echo >/dev/null

.PHONY: release
release:
	@echo >/dev/null
