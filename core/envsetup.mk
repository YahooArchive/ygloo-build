UNAME:=$(shell uname -sm)

HOST_OS:=$(shell uname -s)
HOST_ARCH:=$(shell uname -m)

ifneq (,$(findstring Linux,$(UNAME)))
    HOST_OS := linux
endif
ifneq (,$(findstring Darwin,$(UNAME)))
    HOST_OS := darwin
endif
ifneq (,$(findstring Macintosh,$(UNAME)))
    HOST_OS := darwin
endif
ifneq (,$(findstring CYGWIN,$(UNAME)))
    HOST_OS := windows
endif
