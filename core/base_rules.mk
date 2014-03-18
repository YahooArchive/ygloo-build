#
# Copyright (C) 2008 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Users can define base-rules-hook in their buildspec.mk to perform
# arbitrary operations as each module is included.
ifdef base-rules-hook
$(if $(base-rules-hook),)
endif

###########################################################
## Common instructions for a generic module.
###########################################################

LOCAL_MODULE := $(strip $(LOCAL_MODULE))
ifeq ($(LOCAL_MODULE),)
  $(error $(LOCAL_PATH): LOCAL_MODULE is not defined)
endif

LOCAL_IS_HOST_MODULE := $(strip $(LOCAL_IS_HOST_MODULE))
ifdef LOCAL_IS_HOST_MODULE
  ifneq ($(LOCAL_IS_HOST_MODULE),true)
    $(error $(LOCAL_PATH): LOCAL_IS_HOST_MODULE must be "true" or empty, not "$(LOCAL_IS_HOST_MODULE)")
  endif
  my_prefix := HOST_
  my_host := host-
else
  my_prefix := TARGET_
  my_host :=
endif

###########################################################
## Validate and define fallbacks for input LOCAL_* variables.
###########################################################

## Dump a .csv file of all modules and their tags
#ifneq ($(tag-list-first-time),false)
#$(shell rm -f tag-list.csv)
#tag-list-first-time := false
#endif
#$(shell echo $(lastword $(filter-out config/% out/%,$(MAKEFILE_LIST))),$(LOCAL_MODULE),$(strip $(LOCAL_MODULE_CLASS)),$(subst $(space),$(comma),$(sort $(LOCAL_MODULE_TAGS))) >> tag-list.csv)

LOCAL_MODULE_TAGS := $(sort $(LOCAL_MODULE_TAGS))
ifeq (,$(LOCAL_MODULE_TAGS))
  LOCAL_MODULE_TAGS := optional
endif

# User tags are not allowed anymore.  Fail early because it will not be installed
# like it used to be.
ifneq ($(filter $(LOCAL_MODULE_TAGS),user),)
  $(warning *** Module name: $(LOCAL_MODULE))
  $(warning *** Makefile location: $(LOCAL_MODULE_MAKEFILE))
  $(warning * )
  $(warning * Module is attempting to use the 'user' tag.  This)
  $(warning * used to cause the module to be installed automatically.)
  $(warning * Now, the module must be listed in the PRODUCT_PACKAGES)
  $(warning * section of a product makefile to have it installed.)
  $(warning * )
  $(error user tag detected on module.)
endif

# Only the tags mentioned in this test are expected to be set by module
# makefiles. Anything else is either a typo or a source of unexpected
# behaviors.
ifneq ($(filter-out debug eng tests optional samples shell_ash shell_mksh,$(LOCAL_MODULE_TAGS)),)
$(warning unusual tags $(LOCAL_MODULE_TAGS) on $(LOCAL_MODULE) at $(LOCAL_PATH))
endif

# Add implicit tags.
#
# If the local directory or one of its parents contains a MODULE_LICENSE_GPL
# file, tag the module as "gnu".  Search for "*_GPL*" and "*_MPL*" so that we can also
# find files like MODULE_LICENSE_GPL_AND_AFL but exclude files like
# MODULE_LICENSE_LGPL.
#
gpl_license_file := $(call find-parent-file,$(LOCAL_PATH),MODULE_LICENSE*_GPL* MODULE_LICENSE*_MPL*)
ifneq ($(gpl_license_file),)
  LOCAL_MODULE_TAGS += gnu
  ALL_GPL_MODULE_LICENSE_FILES := $(sort $(ALL_GPL_MODULE_LICENSE_FILES) $(gpl_license_file))
endif

LOCAL_MODULE_CLASS := $(strip $(LOCAL_MODULE_CLASS))
ifneq ($(words $(LOCAL_MODULE_CLASS)),1)
  $(error $(LOCAL_PATH): LOCAL_MODULE_CLASS must contain exactly one word, not "$(LOCAL_MODULE_CLASS)")
endif

ifneq (true,$(LOCAL_UNINSTALLABLE_MODULE))
LOCAL_MODULE_PATH := $(strip $(LOCAL_MODULE_PATH))
ifeq ($(LOCAL_MODULE_PATH),)
  ifdef LOCAL_IS_HOST_MODULE
    partition_tag :=
  else
  ifeq (true,$(LOCAL_PROPRIETARY_MODULE))
    partition_tag := _VENDOR
  else
    # The definition of should-install-to-system will be different depending
    # on which goal (e.g., sdk or just droid) is being built.
    partition_tag := $(if $(call should-install-to-system,$(LOCAL_MODULE_TAGS)),,_DATA)
  endif
  endif
  install_path_var := $(my_prefix)OUT$(partition_tag)_$(LOCAL_MODULE_CLASS)
  ifeq (true,$(LOCAL_PRIVILEGED_MODULE))
    install_path_var := $(install_path_var)_PRIVILEGED
  endif

  LOCAL_MODULE_PATH := $($(install_path_var))
  ifeq ($(strip $(LOCAL_MODULE_PATH)),)
    $(error $(LOCAL_PATH): unhandled install path "$(install_path_var)")
  endif
endif
endif # not LOCAL_UNINSTALLABLE_MODULE

ifneq ($(strip $(LOCAL_BUILT_MODULE)$(LOCAL_INSTALLED_MODULE)),)
  $(error $(LOCAL_PATH): LOCAL_BUILT_MODULE and LOCAL_INSTALLED_MODULE must not be defined by component makefiles)
endif

# Make sure that this IS_HOST/CLASS/MODULE combination is unique.
module_id := MODULE.$(if \
    $(LOCAL_IS_HOST_MODULE),HOST,TARGET).$(LOCAL_MODULE_CLASS).$(LOCAL_MODULE)
ifdef $(module_id)
$(error $(LOCAL_PATH): $(module_id) already defined by $($(module_id)))
endif
$(module_id) := $(LOCAL_PATH)

intermediates := $(call local-intermediates-dir)
intermediates.COMMON := $(call local-intermediates-dir,COMMON)

###########################################################
# Pick a name for the intermediate and final targets
###########################################################
ifndef LOCAL_MODULE_STEM
  LOCAL_MODULE_STEM := $(LOCAL_MODULE)
endif

ifndef LOCAL_BUILT_MODULE_STEM
  LOCAL_BUILT_MODULE_STEM := $(LOCAL_MODULE_STEM)$(LOCAL_MODULE_SUFFIX)
endif

ifndef LOCAL_INSTALLED_MODULE_STEM
  LOCAL_INSTALLED_MODULE_STEM := $(LOCAL_MODULE_STEM)$(LOCAL_MODULE_SUFFIX)
endif

###########################################################
## make clean- targets
###########################################################
cleantarget := clean-$(LOCAL_MODULE)
$(cleantarget) : PRIVATE_MODULE := $(LOCAL_MODULE)
$(cleantarget) : PRIVATE_CLEAN_FILES := \
    $(LOCAL_BUILT_MODULE) \
    $(LOCAL_INSTALLED_MODULE) \
    $(intermediates)
$(cleantarget)::
	@echo "Clean: $(PRIVATE_MODULE)"
	@echo "  files=$(PRIVATE_CLEAN_FILES)"

#	$(hide) rm -rf $(PRIVATE_CLEAN_FILES)

###########################################################
## Common definitions for module.
###########################################################

# Propagate local configuration options to this target.
$(LOCAL_INTERMEDIATE_TARGETS) : PRIVATE_PATH:=$(LOCAL_PATH)
$(LOCAL_INTERMEDIATE_TARGETS) : PRIVATE_AAPT_FLAGS:= $(LOCAL_AAPT_FLAGS)
$(LOCAL_INTERMEDIATE_TARGETS) : PRIVATE_JAVA_LIBRARIES:= $(LOCAL_JAVA_LIBRARIES)
$(LOCAL_INTERMEDIATE_TARGETS) : PRIVATE_MANIFEST_PACKAGE_NAME:= $(LOCAL_MANIFEST_PACKAGE_NAME)
$(LOCAL_INTERMEDIATE_TARGETS) : PRIVATE_MANIFEST_INSTRUMENTATION_FOR:= $(LOCAL_MANIFEST_INSTRUMENTATION_FOR)

$(LOCAL_INTERMEDIATE_TARGETS) : PRIVATE_ALL_JAVA_LIBRARIES:= $(full_java_libs)
$(LOCAL_INTERMEDIATE_TARGETS) : PRIVATE_IS_HOST_MODULE := $(LOCAL_IS_HOST_MODULE)
$(LOCAL_INTERMEDIATE_TARGETS) : PRIVATE_HOST:= $(my_host)

$(LOCAL_INTERMEDIATE_TARGETS) : PRIVATE_INTERMEDIATES_DIR:= $(intermediates)

# Tell the module and all of its sub-modules who it is.
$(LOCAL_INTERMEDIATE_TARGETS) : PRIVATE_MODULE:= $(LOCAL_MODULE)

# Provide a short-hand for building this module.
# We name both BUILT and INSTALLED in case
# LOCAL_UNINSTALLABLE_MODULE is set.
.PHONY: $(LOCAL_MODULE)
$(LOCAL_MODULE): $(LOCAL_BUILT_MODULE) $(LOCAL_INSTALLED_MODULE)

###########################################################
## Register with ALL_MODULES
###########################################################

ALL_MODULES += $(LOCAL_MODULE)

# Don't use += on subvars, or else they'll end up being
# recursively expanded.
ALL_MODULES.$(LOCAL_MODULE).CLASS := \
    $(ALL_MODULES.$(LOCAL_MODULE).CLASS) $(LOCAL_MODULE_CLASS)
ALL_MODULES.$(LOCAL_MODULE).PATH := \
    $(ALL_MODULES.$(LOCAL_MODULE).PATH) $(LOCAL_PATH)
ALL_MODULES.$(LOCAL_MODULE).TAGS := \
    $(ALL_MODULES.$(LOCAL_MODULE).TAGS) $(LOCAL_MODULE_TAGS)
ALL_MODULES.$(LOCAL_MODULE).CHECKED := \
    $(ALL_MODULES.$(LOCAL_MODULE).CHECKED) $(LOCAL_CHECKED_MODULE)
ALL_MODULES.$(LOCAL_MODULE).BUILT := \
    $(ALL_MODULES.$(LOCAL_MODULE).BUILT) $(LOCAL_BUILT_MODULE)
ALL_MODULES.$(LOCAL_MODULE).INSTALLED := \
    $(strip $(ALL_MODULES.$(LOCAL_MODULE).INSTALLED) $(LOCAL_INSTALLED_MODULE))
ALL_MODULES.$(LOCAL_MODULE).REQUIRED := \
    $(ALL_MODULES.$(LOCAL_MODULE).REQUIRED) $(LOCAL_REQUIRED_MODULES)
ALL_MODULES.$(LOCAL_MODULE).EVENT_LOG_TAGS := \
    $(ALL_MODULES.$(LOCAL_MODULE).EVENT_LOG_TAGS) $(event_log_tags)
ALL_MODULES.$(LOCAL_MODULE).INTERMEDIATE_SOURCE_DIR := \
    $(ALL_MODULES.$(LOCAL_MODULE).INTERMEDIATE_SOURCE_DIR) $(LOCAL_INTERMEDIATE_SOURCE_DIR)
ALL_MODULES.$(LOCAL_MODULE).MAKEFILE := \
    $(ALL_MODULES.$(LOCAL_MODULE).MAKEFILE) $(LOCAL_MODULE_MAKEFILE)
ifdef LOCAL_MODULE_OWNER
ALL_MODULES.$(LOCAL_MODULE).OWNER := \
    $(sort $(ALL_MODULES.$(LOCAL_MODULE).OWNER) $(LOCAL_MODULE_OWNER))
endif

INSTALLABLE_FILES.$(LOCAL_INSTALLED_MODULE).MODULE := $(LOCAL_MODULE)

###########################################################
## Take care of LOCAL_MODULE_TAGS
###########################################################

# Keep track of all the tags we've seen.
ALL_MODULE_TAGS := $(sort $(ALL_MODULE_TAGS) $(LOCAL_MODULE_TAGS))

# Add this module to the tag list of each specified tag.
# Don't use "+=". If the variable hasn't been set with ":=",
# it will default to recursive expansion.
$(foreach tag,$(LOCAL_MODULE_TAGS),\
    $(eval ALL_MODULE_TAGS.$(tag) := \
        $(ALL_MODULE_TAGS.$(tag)) \
        $(LOCAL_INSTALLED_MODULE)))

# Add this module name to the tag list of each specified tag.
$(foreach tag,$(LOCAL_MODULE_TAGS),\
    $(eval ALL_MODULE_NAME_TAGS.$(tag) += $(LOCAL_MODULE)))

#:vi noexpandtab
