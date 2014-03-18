linked_module:=$(OBJSDIR)/$(LOCAL_MODULE)$(TARGET_SHLIB_SUFFIX)
all_objects:=$(addprefix $(OBJSDIR)/intermediate/$(LOCAL_MODULE)/,$(addsuffix .o, $(basename $(LOCAL_SRC_FILES))))
private_static_deps:=$(addprefix $(OBJSDIR)/,$(addsuffix .a,$(LOCAL_STATIC_LIBRARIES)))

LOCAL_INTERMEDIATE_TARGETS := $(all_objects)
include $(BUILD_SYSTEM)/binary.mk

-include $(all_objects:%.o=%.P)

$(linked_module): PRIVATE_ALL_OBJECTS := $(all_objects)
$(linked_module): PRIVATE_STATIC_DEPS := $(private_static_deps)
$(linked_module): PRIVATE_ALL_SHARED_LIBRARIES := $(built_shared_libraries)

$(linked_module): PRIVATE_CC := $(TARGET_CC)
$(linked_module): PRIVATE_CXX := $(TARGET_CXX)
$(linked_module): PRIVATE_LDFLAGS := $(LOCAL_LDFLAGS) $(TARGET_LDFLAGS)
$(linked_module): PRIVATE_LDLIBS := $(LOCAL_LDLIBS) $(TARGET_LDLIBS)
$(linked_module): PRIVATE_OS := $(TARGET_OS)
$(linked_module): PRIVATE_ARCH := $(TARGET_ARCH)

$(linked_module): $(all_objects) $(private_static_deps)
	$(transform-o-to-shared-lib)
