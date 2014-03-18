COMBODIR := out/target/ios
COMBOARCHS := armv7 armv7s arm64 i386 x86_64

COMBOLIBS :=
COMBOLIBS += $(COMBODIR)/libyahoo_yosal.a
COMBOLIBS += $(COMBODIR)/libyahoo_ymagine.a
COMBOLIBS += $(COMBODIR)/libyahoo_yperwave.a
COMBOLIBS += $(COMBODIR)/libyahoo_flickr.a

####################
# Yosal
####################

STATICLIBS_ALLARCH_YOSAL :=
STATICLIBS_ALLARCH_YOSAL += out/target/ios-armv7/libyahoo_yosal.a
STATICLIBS_ALLARCH_YOSAL += out/target/ios-armv7s/libyahoo_yosal.a
STATICLIBS_ALLARCH_YOSAL += out/target/ios-arm64/libyahoo_yosal.a
STATICLIBS_ALLARCH_YOSAL += out/target/ios-i386/libyahoo_yosal.a
STATICLIBS_ALLARCH_YOSAL += out/target/ios-x86_64/libyahoo_yosal.a

libs/armeabi/libyahoo_yosal.so: $(OBJSDIR)

# Create FAT static library
$(COMBODIR)/libyahoo_yosal.a: $(STATICLIBS_ALLARCH_YOSAL)
	$(transform-a-to-fat-lib)

####################
# Ymagine
####################

STATICLIBS_ALLARCH_YMAGINE :=
STATICLIBS_ALLARCH_YMAGINE += out/target/ios-armv7/libyahoo_ymagine.a
STATICLIBS_ALLARCH_YMAGINE += out/target/ios-armv7s/libyahoo_ymagine.a
STATICLIBS_ALLARCH_YMAGINE += out/target/ios-arm64/libyahoo_ymagine.a
STATICLIBS_ALLARCH_YMAGINE += out/target/ios-i386/libyahoo_ymagine.a
STATICLIBS_ALLARCH_YMAGINE += out/target/ios-x86_64/libyahoo_ymagine.a

ALL_STATIC_LIBS_YMAGINE :=
ALL_STATIC_LIBS_YMAGINE += $(OBJSDIR)/libyahoo_jpegturbo.a
ALL_STATIC_LIBS_YMAGINE += $(OBJSDIR)/libyahoo_yosal.a
ifeq ($(YMAGINE_CONFIG_XMP),true)
ALL_STATIC_LIBS_YMAGINE += $(OBJSDIR)/libyahoo_expat.a
endif
ALL_STATIC_LIBS_YMAGINE += $(OBJSDIR)/libyahoo_ymagine_main.a
ifeq ($(YMAGINE_CONFIG_CLASSIFIER),true)
ALL_STATIC_LIBS_YMAGINE += $(OBJSDIR)/libyahoo_ccv.a
ALL_STATIC_LIBS_YMAGINE += $(OBJSDIR)/libyahoo_ymagine_vision_main.a
endif

libs/armeabi/libyahoo_ymagine.so: $(OBJSDIR)

# Create FAT static library
$(COMBODIR)/libyahoo_ymagine.a: $(STATICLIBS_ALLARCH_YMAGINE)
	$(transform-a-to-fat-lib)

# Combine multiple static libraries in one for a given architecture
$(OBJSDIR)/libyahoo_ymagine.a: $(ALL_STATIC_LIBS_YMAGINE)
	$(transform-a-to-static-lib)

####################
# Yperwave
####################

STATICLIBS_ALLARCH_YPERWAVE :=
STATICLIBS_ALLARCH_YPERWAVE += out/target/ios-armv7/libyahoo_yperwave.a
STATICLIBS_ALLARCH_YPERWAVE += out/target/ios-armv7s/libyahoo_yperwave.a
STATICLIBS_ALLARCH_YPERWAVE += out/target/ios-arm64/libyahoo_yperwave.a
STATICLIBS_ALLARCH_YPERWAVE += out/target/ios-i386/libyahoo_yperwave.a
STATICLIBS_ALLARCH_YPERWAVE += out/target/ios-x86_64/libyahoo_yperwave.a

ALL_STATIC_LIBS_YPERWAVE :=
ALL_STATIC_LIBS_YPERWAVE += $(OBJSDIR)/libyahoo_zlib.a
ALL_STATIC_LIBS_YPERWAVE += $(OBJSDIR)/libyahoo_jansson.a
ALL_STATIC_LIBS_YPERWAVE += $(OBJSDIR)/libyahoo_axtls.a
ALL_STATIC_LIBS_YPERWAVE += $(OBJSDIR)/libyahoo_curl.a
ALL_STATIC_LIBS_YPERWAVE += $(OBJSDIR)/libyahoo_yosal.a
ALL_STATIC_LIBS_YPERWAVE += $(OBJSDIR)/libyahoo_yperwave_main.a

libs/armeabi/libyahoo_yperwave.so: $(OBJSDIR)

# Create FAT static library
$(COMBODIR)/libyahoo_yperwave.a: $(STATICLIBS_ALLARCH_YPERWAVE)
	$(transform-a-to-fat-lib)

# Combine multiple static libraries in one for a given architecture
$(OBJSDIR)/libyahoo_yperwave.a: $(ALL_STATIC_LIBS_YPERWAVE)
	$(transform-a-to-static-lib)

####################
# Flickr
####################

STATICLIBS_ALLARCH_FLICKR :=
STATICLIBS_ALLARCH_FLICKR += out/target/ios-armv7/libyahoo_flickr.a
STATICLIBS_ALLARCH_FLICKR += out/target/ios-armv7s/libyahoo_flickr.a
STATICLIBS_ALLARCH_FLICKR += out/target/ios-arm64/libyahoo_flickr.a
STATICLIBS_ALLARCH_FLICKR += out/target/ios-i386/libyahoo_flickr.a
STATICLIBS_ALLARCH_FLICKR += out/target/ios-x86_64/libyahoo_flickr.a

ALL_STATIC_LIBS_FLICKR :=
ALL_STATIC_LIBS_FLICKR += $(OBJSDIR)/libyahoo_zlib.a
ALL_STATIC_LIBS_FLICKR += $(OBJSDIR)/libyahoo_jansson.a
ALL_STATIC_LIBS_FLICKR += $(OBJSDIR)/libyahoo_axtls.a
ALL_STATIC_LIBS_FLICKR += $(OBJSDIR)/libyahoo_curl.a
ALL_STATIC_LIBS_FLICKR += $(OBJSDIR)/libyahoo_yosal.a
ALL_STATIC_LIBS_FLICKR += $(OBJSDIR)/libyahoo_yperwave_main.a
ALL_STATIC_LIBS_FLICKR += $(OBJSDIR)/libyahoo_flickr_main.a

libs/armeabi/libyahoo_flickr.so: $(OBJSDIR)

# Create FAT static library
$(COMBODIR)/libyahoo_flickr.a: $(STATICLIBS_ALLARCH_FLICKR)
	$(transform-a-to-fat-lib)

# Combine multiple static libraries in one for a given architecture
$(OBJSDIR)/libyahoo_flickr.a: $(ALL_STATIC_LIBS_FLICKR)
	$(transform-a-to-static-lib)
