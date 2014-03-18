# Target is iOS (device or simulator)
ifeq ($(TARGET_ARCH),)
TARGET_ARCH:=armv7s
endif
TARGET_OS:=ios

OBJSDIR:= out/target/$(TARGET_OS)-$(TARGET_ARCH)
TARGET_DIR:=$(TOPDIR)/$(OBJSDIR)

XCODE_ROOT:=/Applications/Xcode.app
TOOLCHAIN_ROOT:=$(XCODE_ROOT)/Contents/Developer/Toolchains/XcodeDefault.xctoolchain
TOOLCHAIN_PREFIX:=$(TOOLCHAIN_ROOT)/usr/bin/

PLATFORMS_ROOT:=$(XCODE_ROOT)/Contents/Developer/Platforms

ifeq ($(TARGET_ARCH),i386)
SDK_ROOT := $(PLATFORMS_ROOT)/iPhoneSimulator.platform/Developer/SDKs
SDK_PREFIX := $(SDK_ROOT)/iPhoneSimulator6.0.sdk

TARGET_CFLAGS += -arch i386
TARGET_CFLAGS += -mios-simulator-version-min=5.0

else ifeq ($(TARGET_ARCH),x86_64)
SDK_ROOT := $(PLATFORMS_ROOT)/iPhoneSimulator.platform/Developer/SDKs
SDK_PREFIX := $(SDK_ROOT)/iPhoneSimulator6.0.sdk

TARGET_CFLAGS += -arch x86_64
TARGET_CFLAGS += -mios-simulator-version-min=6.0

else
SDK_ROOT := $(PLATFORMS_ROOT)/iPhoneOS.platform/Developer/SDKs

SDK_PREFIX := $(SDK_ROOT)/iPhoneOS7.0.sdk
ifeq (,$(wildcard $(SDK_PREFIX)))
SDK_PREFIX := $(SDK_ROOT)/iPhoneOS6.1.sdk
endif

endif

ifeq ($(TARGET_ARCH),arm64)
# armv7a
TARGET_CFLAGS += -arch arm64
TARGET_CFLAGS += -miphoneos-version-min=7.0
endif
ifeq ($(TARGET_ARCH),armv7s)
# armv7a
TARGET_CFLAGS += -arch armv7s
TARGET_CFLAGS += -miphoneos-version-min=5.0
endif
ifeq ($(TARGET_ARCH),armv7)
TARGET_CFLAGS += -arch armv7
TARGET_CFLAGS += -miphoneos-version-min=5.0
endif
ifeq ($(TARGET_ARCH),armv6)
TARGET_CFLAGS += -arch armv6
TARGET_CFLAGS += -miphoneos-version-min=5.0
endif
ifeq ($(TARGET_ARCH),i386)
TARGET_CFLAGS += -arch i386
TARGET_CFLAGS += -mios-simulator-version-min=5.0
endif

TARGET_CFLAGS += -isysroot $(SDK_PREFIX)
TARGET_CFLAGS += -I$(TOOLCHAIN_ROOT)/usr/include
TARGET_CFLAGS += -DIOS

ifeq ($(BUILD_DEBUG),true)
TARGET_CFLAGS += -DDEBUG -UNDEBUG
TARGET_CFLAGS += -O0 -g
else
TARGET_CFLAGS += -UDEBUG -DNDEBUG
TARGET_CFLAGS += -Os
TARGET_CFLAGS += -fomit-frame-pointer
TARGET_CFLAGS += -fno-strict-aliasing
# TARGET_CFLAGS += -finline-limit=64
endif
ifeq ($(BUILD_STRICT),true)
TARGET_CFLAGS += -Wall -Werror
endif

TARGET_COMPILER:=clang
TARGET_CC:=$(TOOLCHAIN_PREFIX)clang -x c
TARGET_CXX:=$(TOOLCHAIN_PREFIX)clang -x c++
TARGET_OBJC:=$(TOOLCHAIN_PREFIX)clang -x objective-c

TARGET_LIBTOOL:=$(TOOLCHAIN_PREFIX)libtool
TARGET_LIBTOOLFLAGS:=

TARGET_LIPO:=lipo
TARGET_LIPOFLAGS:=

TARGET_AR:=$(TOOLCHAIN_PREFIX)ar
TARGET_RANLIB:=$(TOOLCHAIN_PREFIX)ranlib

TARGET_LDLIBS += -L$(TOOLCHAIN_SYSROOT)/usr/lib
TARGET_LDLIBS += -lc -lm
