# Target is current host system
TARGET_OS:=$(HOST_OS)
TARGET_ARCH:=$(HOST_ARCH)

OBJSDIR:= out/target/$(TARGET_OS)-$(TARGET_ARCH)
TARGET_DIR:=$(TOPDIR)/$(OBJSDIR)

ifneq ($(USE_CLANG),)
TARGET_COMPILER:=clang
TARGET_CC:=clang
TARGET_CXX:=clang++
else
TARGET_COMPILER:=gcc
TARGET_CC:=gcc
TARGET_CXX:=g++
endif

ifneq ($(findstring ccc-analyzer,$(CC)),)
export CCC_CC := $(TARGET_CC)
TARGET_CC := $(CC)
endif

ifneq ($(findstring c++-analyzer,$(CXX)),)
export CCC_CXX := $(TARGET_CXX)
TARGET_CXX := $(CXX)
endif

TARGET_AR:=ar
TARGET_RANLIB:=ranlib

#TARGET_CC += -m32
#TARGET_CXX += -m32

ifeq ($(TARGET_OS),darwin)
TARGET_LIBTOOL:=libtool
TARGET_LIBTOOLFLAGS:=
else
TARGET_LIBTOOL:=$(BUILD_TOOLS)/libmerge.sh
TARGET_LIBTOOLFLAGS:=
endif

ifeq ($(BUILD_DEBUG),true)
TARGET_CFLAGS += -DDEBUG -UNDEBUG
TARGET_CFLAGS += -O0 -g
ifneq ($(USE_CLANG_SANITIZE_ADDRESS),)
TARGET_CFLAGS += -fno-omit-frame-pointer -fno-optimize-sibling-calls -fsanitize=address
TARGET_LDFLAGS += -fsanitize=address
endif
else
TARGET_CFLAGS += -UDEBUG -DNDEBUG
TARGET_CFLAGS += -O3
TARGET_CFLAGS += -fomit-frame-pointer
TARGET_CFLAGS += -march=core2
endif
ifeq ($(BUILD_STRICT),true)
TARGET_CFLAGS += -Wall -Werror
endif

ifeq ($(TARGET_OS),linux)
ifneq (,$(wildcard /home/y/lib64))
TARGET_LDFLAGS := -Wl,-rpath,/home/y/lib64
endif
endif

TARGET_LDLIBS += -lpthread

ifeq ($(TARGET_OS),linux)
TARGET_LDLIBS += -lrt
endif

