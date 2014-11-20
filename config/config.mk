YCONFIG_PATH:=$(call my-dir)

# Directories layout
YCONFIG_BASE_PATH:=$(YCONFIG_PATH)/..
YCONFIG_TOP_PATH:=$(YCONFIG_BASE_PATH)/..
YCONFIG_CORE_PATH:=$(YCONFIG_BASE_PATH)/core

YCONFIG_EXTERNAL:=$(YCONFIG_TOP_PATH)/external
YCONFIG_FRAMEWORK:=$(YCONFIG_TOP_PATH)/framework

include $(YCONFIG_CORE_PATH)/setup.mk

# SSL implementation to use (axtls or openssl)
ifeq ($(YCONFIG_OPTION_SSL),)
YCONFIG_OPTION_SSL:=openssl
endif

# Features
YCONFIG_OPTION_JSON:=true

# Local mirrors of 3rd parties modules
ZLIB_ROOT:=$(YCONFIG_EXTERNAL)/zlib
LZF_ROOT:=$(YCONFIG_EXTERNAL)/liblzf
CARES_ROOT:=$(YCONFIG_EXTERNAL)/c-ares
AXTLS_ROOT:=$(YCONFIG_EXTERNAL)/axtls
OPENSSL_ROOT:=$(YCONFIG_EXTERNAL)/openssl
CURL_ROOT:=$(YCONFIG_EXTERNAL)/curl
JANSSON_ROOT:=$(YCONFIG_EXTERNAL)/jansson
JPEGTURBO_ROOT:=$(YCONFIG_EXTERNAL)/jpeg-turbo
WEBP_ROOT:=$(YCONFIG_EXTERNAL)/webp
PNG_ROOT:=$(YCONFIG_EXTERNAL)/libpng
CCV_ROOT:=$(YCONFIG_EXTERNAL)/ccv
OPENCV_ROOT:=$(YCONFIG_EXTERNAL)/opencv
EXPAT_ROOT:=$(YCONFIG_EXTERNAL)/expat
VPX_ROOT:=$(YCONFIG_EXTERNAL)/libvpx
WEBM_ROOT:=$(YCONFIG_EXTERNAL)/webm
WEBMTOOLS_ROOT:=$(YCONFIG_EXTERNAL)/webm-tools

# Core modules
YOSAL_ROOT:=$(YCONFIG_FRAMEWORK)/yosal
YPERWAVE_ROOT:=$(YCONFIG_FRAMEWORK)/yperwave
YMAGINE_ROOT:=$(YCONFIG_FRAMEWORK)/ymagine
FLICKR_ROOT:=$(YCONFIG_FRAMEWORK)/FlickrSDK

# Dependencies
CURL_STATIC_LIBRARIES := libyahoo_curl
ifeq ($(YCONFIG_OPTION_SSL),axtls)
CURL_STATIC_LIBRARIES += libyahoo_axtls
endif
ifeq ($(YCONFIG_OPTION_SSL),openssl)
CURL_STATIC_LIBRARIES += libssl_static
CURL_STATIC_LIBRARIES += libcrypto_static
endif
CURL_STATIC_LIBRARIES += libyahoo_jansson
CURL_STATIC_LIBRARIES += libyahoo_yosal
CURL_STATIC_LIBRARIES += libyahoo_zlib

YMAGINE_STATIC_LIBRARIES := libyahoo_ymagine_main
YMAGINE_STATIC_LIBRARIES += libyahoo_jpegturbo
YMAGINE_STATIC_LIBRARIES += libyahoo_png
YMAGINE_STATIC_LIBRARIES += libyahoo_webpdec
YMAGINE_STATIC_LIBRARIES += libyahoo_webpenc
YMAGINE_STATIC_LIBRARIES += libyahoo_expat
YMAGINE_STATIC_LIBRARIES += libyahoo_yosal
YMAGINE_STATIC_LIBRARIES += libyahoo_zlib

YPERWAVE_STATIC_LIBRARIES := libyahoo_yperwave_main
ifeq ($(YPERWAVE_OPTION_SPDY),true)
YPERWAVE_STATIC_LIBRARIES += libyahoo_spdylay
endif
YPERWAVE_STATIC_LIBRARIES += $(CURL_STATIC_LIBRARIES)

FLICKR_STATIC_LIBRARIES := libyahoo_flickr_main
FLICKR_STATIC_LIBRARIES += $(YPERWAVE_STATIC_LIBRARIES)

SPDYLAY_EXES :=
ifeq ($(YPERWAVE_OPTION_SPDY),true)
SPDYLAY_EXES := $(OBJSDIR)/bin/spdycli
endif

CCV_CUDA:=false
ifneq (,$(TARGET_NVDIR))
ifneq (,$(wildcard $(TARGET_NVDIR)))
# CCV_CUDA:=true
endif
endif
ifeq ($(CCV_CUDA),true)
CCV_LDLIBS := -Wl,-rpath,/usr/local/cuda/lib -L/usr/local/cuda/lib
CCV_LDLIBS += -lcuda -lcudart -lcublas
endif

ifeq ($(TARGET_OS),darwin)
CCV_LDLIBS += -framework Accelerate
endif

