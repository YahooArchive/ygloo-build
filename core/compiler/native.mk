# Target is current host system
TARGET_OS:=$(HOST_OS)
TARGET_ARCH:=$(HOST_ARCH)
TARGET_ARCH_ABI:=$(TARGET_ARCH)

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

TARGET_NASM:=nasm
TARGET_NASMFLAGS:=

ifeq ($(TARGET_OS),darwin)
# Nasm on MacOSX <= 10.9 doesn't support macho64 output. Default to
# more recent local copy of nasm in tools/ directory
TARGET_NASM:=$(BUILD_TOOLS)/nasm/darwin/nasm
TARGET_NASMFLAGS += -fmacho64 -DMACHO -D__x86_64__
ifeq (,$(wildcard $(TARGET_NASM)))
# Use nasm from MacPort
TARGET_NASM=/opt/local/bin/nasm
endif
ifeq (,$(wildcard $(TARGET_NASM)))
# Use nasm from Brew
TARGET_NASM=/usr/local/bin/nasm
endif
ifeq (,$(wildcard $(TARGET_NASM)))
TARGET_NASM=nasm
endif
endif
ifeq ($(TARGET_OS),linux)
TARGET_NASMFLAGS += -felf64 -DELF -D__x86_64__
endif

TARGET_NVDIR:=/usr/local/cuda
ifeq (,$(wildcard $(TARGET_NVDIR)))
TARGET_NVDIR:=
TARGET_NVCC:=nvcc
else
TARGET_NVCC:=$(TARGET_NVDIR)/bin/nvcc
endif
TARGET_NVCCFLAGS:=--use_fast_math -arch=sm_30 --machine 64

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
TARGET_CFLAGS += -m64
ifeq ($(TARGET_OS),linux)
TARGET_CFLAGS += -march=core2 -mtune=native
else
TARGET_CFLAGS += -march=core2 -mtune=native
endif
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

