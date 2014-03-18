linked_module:=$(OBJSDIR)/$(LOCAL_MODULE).a
all_objects:=$(addprefix $(OBJSDIR)/intermediate/$(LOCAL_MODULE)/,$(addsuffix .o, $(basename $(LOCAL_SRC_FILES))))
private_static_deps:=$(addprefix $(OBJSDIR)/,$(addsuffix .a,$(LOCAL_STATIC_LIBRARIES)))

LOCAL_INTERMEDIATE_TARGETS := $(all_objects)
include $(BUILD_SYSTEM)/binary.mk

-include $(all_objects:%.o=%.P)

$(linked_module): PRIVATE_ALL_OBJECTS := $(all_objects)
$(linked_module): PRIVATE_AR := $(TARGET_AR)
$(linked_module): PRIVATE_RANLIB := $(TARGET_RANLIB)
$(linked_module): $(all_objects) $(private_static_deps)
	@mkdir -p $(dir $@)
	@rm -f $@
	$(PRIVATE_AR) rcv $@ $(PRIVATE_ALL_OBJECTS)
	$(PRIVATE_RANLIB) $@
