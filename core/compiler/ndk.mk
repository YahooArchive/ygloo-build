# Target is current host system
TARGET_OS:=android
TARGET_ARCH:=arm
TARGET_ARCH_ABI:=armeabi-v7a

OBJSDIR:= out/target/$(TARGET_OS)-$(TARGET_ARCH)
TARGET_DIR:=$(TOPDIR)/$(OBJSDIR)

OBJSDIR:=$(TARGET_DIR)

TARGET_NDK_ROOT:=$(ANDROID_NDK_HOME)
ifeq (,$(TARGET_NDK_ROOT))
TARGET_NDK_ROOT:=$(HOME)/data/android/build/android-ndk-r10b
endif


ifeq ($(TARGET_ARCH),x86)
# x86
NDK_CPU:=x86
NDK_ARCH:=i686-linux-android
else
# arm
NDK_CPU:=arm-linux-androideabi
NDK_ARCH:=arm-linux-androideabi
endif

NDK_TOOLCHAIN_OS:=$(HOST_OS)
ifeq ($(HOST_OS),darwin)
NDK_TOOLCHAIN_OS:=darwin
endif

NDK_TOOLCHAIN_VERSION:=4.9

NDK_TOOLCHAIN:=$(TARGET_NDK_ROOT)/toolchains/$(NDK_CPU)-$(NDK_TOOLCHAIN_VERSION)/prebuilt/$(NDK_TOOLCHAIN_OS)-x86_64
ifeq (,$(wildcard $(NDK_TOOLCHAIN)))
NDK_TOOLCHAIN:=$(TARGET_NDK_ROOT)/toolchains/$(NDK_CPU)-$(NDK_TOOLCHAIN_VERSION)/prebuilt/$(NDK_TOOLCHAIN_OS)-x86
endif
ifeq (,$(wildcard $(NDK_TOOLCHAIN)))
NDK_TOOLCHAIN_VERSION:=4.8
NDK_TOOLCHAIN:=$(TARGET_NDK_ROOT)/toolchains/$(NDK_CPU)-$(NDK_TOOLCHAIN_VERSION)/prebuilt/$(NDK_TOOLCHAIN_OS)-x86_64
endif
ifeq (,$(wildcard $(NDK_TOOLCHAIN)))
NDK_TOOLCHAIN:=$(TARGET_NDK_ROOT)/toolchains/$(NDK_CPU)-$(NDK_TOOLCHAIN_VERSION)/prebuilt/$(NDK_TOOLCHAIN_OS)-x86
endif
ifeq (,$(wildcard $(NDK_TOOLCHAIN)))
NDK_TOOLCHAIN_VERSION:=4.6
NDK_TOOLCHAIN:=$(TARGET_NDK_ROOT)/toolchains/$(NDK_CPU)-$(NDK_TOOLCHAIN_VERSION)/prebuilt/$(NDK_TOOLCHAIN_OS)-x86_64
endif
ifeq (,$(wildcard $(NDK_TOOLCHAIN)))
NDK_TOOLCHAIN:=$(TARGET_NDK_ROOT)/toolchains/$(NDK_CPU)-$(NDK_TOOLCHAIN_VERSION)/prebuilt/$(NDK_TOOLCHAIN_OS)-x86
endif

NDK_PREFIX:=$(NDK_TOOLCHAIN)/bin/$(NDK_ARCH)-

TARGET_CFLAGS := -fpic
TARGET_CFLAGS += -ffunction-sections -funwind-tables -fstack-protector
TARGET_CFLAGS += -D__ARM_ARCH_5__ -D__ARM_ARCH_5T__ -D__ARM_ARCH_5E__ -D__ARM_ARCH_5TE__
TARGET_CFLAGS += -DANDROID

ifeq ($(TARGET_ARCH),armv7a)
# armv7a
NDK_PLATFORM:=arm
TARGET_CFLAGS += -march=armv7-a -mtune=cortex-a9 -mfloat-abi=softfp -mfpu=vfp
TARGET_CFLAGS += -mthumb
endif
ifeq ($(TARGET_ARCH),armv64)
# arm64
NDK_PLATFORM:=arm64
TARGET_CFLAGS += -march=arm64 -mfloat-abi=softfp -mfpu=vfp
TARGET_CFLAGS += -mthumb
endif
ifeq ($(TARGET_ARCH),arm)
# armv5
NDK_PLATFORM:=arm
TARGET_CFLAGS += -march=armv5te -mtune=xscale -msoft-float
TARGET_CFLAGS += -mthumb
endif
ifeq ($(TARGET_ARCH),x86)
# x86
NDK_PLATFORM:=x86
TARGET_CFLAGS += -march=i686
# TARGET_CFLAGS += -ffunction-sections -funwind-tables -fstrict-aliasing
# TARGET_CFLAGS += -funswitch-loops -finline-limit=300
endif
ifeq ($(TARGET_ARCH),x86_64)
# x86
NDK_PLATFORM:=x86_64
TARGET_CFLAGS += -march=x86_64
# TARGET_CFLAGS += -ffunction-sections -funwind-tables -fstrict-aliasing
# TARGET_CFLAGS += -funswitch-loops -finline-limit=300
endif

# NDK level to build with, default to 14 if available
NDK_LEVEL:=14
NDK_SYSROOT := $(TARGET_NDK_ROOT)/platforms/android-$(NDK_LEVEL)/arch-$(NDK_PLATFORM)
ifeq (,$(wildcard $(NDK_SYSROOT)))
NDK_LEVEL:=10
NDK_SYSROOT := $(TARGET_NDK_ROOT)/platforms/android-$(NDK_LEVEL)/arch-$(NDK_PLATFORM)
endif
ifeq (,$(wildcard $(NDK_SYSROOT)))
NDK_LEVEL:=9
NDK_SYSROOT := $(TARGET_NDK_ROOT)/platforms/android-$(NDK_LEVEL)/arch-$(NDK_PLATFORM)
endif
ifeq (,$(wildcard $(NDK_SYSROOT)))
NDK_LEVEL:=8
NDK_SYSROOT := $(TARGET_NDK_ROOT)/platforms/android-$(NDK_LEVEL)/arch-$(NDK_PLATFORM)
endif
ifeq (,$(wildcard $(NDK_SYSROOT)))
$(info Could not find a valid NDK API level for $(NDK_PLATFORM) in $(TARGET_NDK_ROOT)/platforms, default to 14)
NDK_LEVEL:=14
NDK_SYSROOT := $(TARGET_NDK_ROOT)/platforms/android-$(NDK_LEVEL)/arch-$(NDK_PLATFORM)
endif

ifeq ($(BUILD_DEBUG),true)
TARGET_CFLAGS += -DDEBUG -UNDEBUG
TARGET_CFLAGS += -O0 -g -fno-omit-frame-pointer
else
TARGET_CFLAGS += -UDEBUG -DNDEBUG
TARGET_CFLAGS += -Os -finline-limit=64
TARGET_CFLAGS += -fomit-frame-pointer
TARGET_CFLAGS += -fno-strict-aliasing
endif
ifeq ($(BUILD_STRICT),true)
TARGET_CFLAGS += -Wall -Werror
endif

NDK_CXX_ROOT := $(TARGET_NDK_ROOT)/sources/cxx-stl/gnu-libstdc++/$(NDK_TOOLCHAIN_VERSION)

TARGET_CFLAGS += -I$(NDK_SYSROOT)/usr/include
TARGET_CFLAGS += -I$(NDK_CXX_ROOT)/include
TARGET_CFLAGS += -I$(NDK_CXX_ROOT)/libs/$(TARGET_ARCH_ABI)/include

TARGET_COMPILER:=gcc
TARGET_CC:=$(NDK_PREFIX)gcc
TARGET_CXX:=$(NDK_PREFIX)g++
TARGET_AR:=$(NDK_PREFIX)ar
TARGET_RANLIB:=$(NDK_PREFIX)ranlib
# TARGET_DEBUG_CFLAGS := -g -O0

TARGET_LIBTOOL:=$(BUILD_TOOLS)/libmerge.sh
TARGET_LIBTOOLFLAGS:=

TARGET_LDFLAGS := --sysroot=$(NDK_SYSROOT)

TARGET_LDLIBS += -Wl,--no-undefined -Wl,-z,noexecstack -Wl,-z,relro -Wl,-z,now
TARGET_LDLIBS += -L$(NDK_SYSROOT)/usr/lib
TARGET_LDLIBS += -llog -ljnigraphics
TARGET_LDLIBS += -lstdc++
TARGET_LDLIBS += $(NDK_CXX_ROOT)/libs/$(TARGET_ARCH_ABI)/libsupc++.a
TARGET_LDLIBS += $(NDK_CXX_ROOT)/libs/$(TARGET_ARCH_ABI)/libgnustl_static.a
TARGET_LDLIBS += -lc -lm
