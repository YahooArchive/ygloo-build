define ndk-home
$(strip \
  $(eval _ndk_home := $(patsubst %/,%,$(ANDROID_NDK_HOME))) \
  $(if $(wildcard $(_ndk_home)), \
    $(_ndk_home), \
    $(error ANDROID_NDK_HOME does not exist or is not set) \
  ) \
)
endef

define ndk-clang
$(call ndk-clang-under,$(call ndk-home))
endef

define ndk-clang-under
$(lastword $(sort $(wildcard $(1)/toolchains/llvm-*/prebuilt/*/bin/clang)))
endef

define ndk-scan-build
$(call ndk-scan-build-under,$(call ndk-home))
endef

define ndk-scan-build-under
$(1)/prebuilt/common/scan-build/scan-build
endef
