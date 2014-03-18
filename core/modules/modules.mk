EXES :=
SOLIBS:=
STATICLIBS:=

STATICLIBS += $(OBJSDIR)/libyahoo_yosal.a
STATICLIBS += $(OBJSDIR)/libyahoo_ymagine.a
#STATICLIBS += $(OBJSDIR)/libyahoo_yperwave.a
#STATICLIBS += $(OBJSDIR)/libyahoo_flickr.a

ifeq ($(BUILD_SUPPORT_EXECUTABLE),true)
EXES += $(OBJSDIR)/bin/jpegtran
EXES += $(OBJSDIR)/bin/test-yosal
EXES += $(OBJSDIR)/bin/test-ymagine
#EXES += $(OBJSDIR)/bin/test-effect
#EXES += $(OBJSDIR)/bin/test-yperwave
#EXES += $(OBJSDIR)/bin/test-flickr
#EXES += $(OBJSDIR)/bin/axssl
#EXES += $(SPDYLAY_EXES)
endif

ifeq ($(BUILD_ANDROID),true)
# SOLIBS += libs/armeabi/libyahoo_ymagine.so
# SOLIBS += libs/armeabi-v7a/libyahoo_ymagine.so
# SOLIBS += libs/x86/libyahoo_ymagine.so
endif
ifeq ($(BUILD_SUPPORT_SHARED),true)
SOLIBS += $(OBJSDIR)/libyahoo_ymagine$(TARGET_JNILIB_SUFFIX)
endif

# Aliases
module-yosal: $(OBJSDIR)/bin/test-yosal
module-yperwave: $(OBJSDIR)/bin/test-yperwave
module-ymagine: $(OBJSDIR)/bin/test-ymagine
module-libymagine: $(OBJSDIR)/libyahoo_ymagine$(TARGET_JNILIB_SUFFIX)
module-flickr: $(OBJSDIR)/bin/test-flickr
module-axssl: $(OBJSDIR)/bin/axssl
module-ywatch: $(OBJSDIR)/bin/ywatch
module-spdycli: $(SPDYLAY_EXES)
