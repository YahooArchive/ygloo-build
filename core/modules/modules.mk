EXES:=
SOLIBS:=
STATICLIBS:=

YMAGINE_EXES:=
YMAGINE_STATICLIBS:=
YMAGINE_SOLIBS:=
YMAGINEXS_SOLIBS:=

VISION_EXES:=
VISION_STATICLIBS:=
VISION_SOLIBS:=

VIDEO_EXES:=
VIDEO_STATICLIBS:=
VIDEO_SOLIBS:=

OPENCV_EXES:=
OPENCV_STATICLIBS:=
OPENCV_SOLIBS:=

VSTREAM_EXES:=
VSTREAM_STATICLIBS:=
VSTREAM_SOLIBS:=

YMAGINE_STATICLIBS += $(OBJSDIR)/libyahoo_ymagine.a

OPENCV_STATICLIBS += $(OBJSDIR)/libyahoo_opencv.a

VSTREAM_STATICLIBS += $(OBJSDIR)/libyahoo_srtp.a
ifeq ($(BUILD_SUPPORT_EXECUTABLE),true)
VSTREAM_EXES += $(OBJSDIR)/bin/rtpw
endif

STATICLIBS += $(OBJSDIR)/libyahoo_yosal.a
STATICLIBS += $(OBJSDIR)/libyahoo_ymagine.a
STATICLIBS += $(OBJSDIR)/libyahoo_yperwave.a
STATICLIBS += $(OBJSDIR)/libyahoo_flickr.a

ifeq ($(BUILD_SUPPORT_EXECUTABLE),true)
YMAGINE_EXES += $(OBJSDIR)/bin/ymagine
YMAGINE_EXES += $(OBJSDIR)/bin/test-ymagine-unit

# VISION_EXES += $(OBJSDIR)/bin/cnnclassify
VISION_EXES += $(OBJSDIR)/bin/image-net

# VISION_EXES += $(OBJSDIR)/bin/cnnclassify
VIDEO_EXES += $(OBJSDIR)/bin/image-net

EXES += $(OBJSDIR)/bin/test-yosal
EXES += $(OBJSDIR)/bin/test-effect
EXES += $(OBJSDIR)/bin/test-yperwave
EXES += $(OBJSDIR)/bin/test-flickr
EXES += $(OBJSDIR)/bin/axssl
EXES += $(OBJSDIR)/bin/jpegtran
EXES += $(SPDYLAY_EXES)
endif

ifeq ($(BUILD_ANDROID),true)
# SOLIBS += libs/armeabi/libyahoo_ymagine.so
# SOLIBS += libs/armeabi-v7a/libyahoo_ymagine.so
# SOLIBS += libs/x86/libyahoo_ymagine.so
endif
ifeq ($(BUILD_SUPPORT_SHARED),true)
YMAGINE_SOLIBS += $(OBJSDIR)/libyahoo_ymagine$(TARGET_JNILIB_SUFFIX)
YMAGINEXS_SOLIBS += $(OBJSDIR)/libyahoo_ymaginexs$(TARGET_JNILIB_SUFFIX)
VIDEO_SOLIBS += $(OBJSDIR)/libyahoo_ymagine_video$(TARGET_JNILIB_SUFFIX)
endif

EXES += $(YMAGINE_EXES)
STATICLIBS += $(YMAGINE_STATICLIBS)
SOLIBS += $(YMAGINE_SOLIBS)

EXES += $(VISION_EXES)
STATICLIBS += $(VISION_STATICLIBS)
SOLIBS += $(VISION_SOLIBS)

# Aliases
module-yosal: $(OBJSDIR)/bin/test-yosal
module-yperwave: $(OBJSDIR)/bin/test-yperwave
module-ymagine: $(YMAGINE_EXES) $(YMAGINE_SOLIBS) $(YMAGINE_STATICLIBS)
module-ymaginexs: $(YMAGINEXS_SOLIBS)
module-vision: $(VISION_EXES) $(VISION_SOLIBS) $(VISION_STATICLIBS)
module-video: $(VIDEO_EXES) $(VIDEO_SOLIBS) $(VIDEO_STATICLIBS)
module-flickr: $(OBJSDIR)/bin/test-flickr
module-axssl: $(OBJSDIR)/bin/axssl
module-ywatch: $(OBJSDIR)/bin/ywatch
module-spdycli: $(SPDYLAY_EXES)
module-png: $(OBJSDIR)/bin/pngtest
module-opencv: $(OPENCV_STATICLIBS)
module-vstream: $(VSTREAM_EXES) $(VSTREAM_SOLIBS) $(VSTREAM_STATICLIBS)
