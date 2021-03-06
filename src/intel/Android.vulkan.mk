# Copyright © 2017 Intel Corporation
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
include $(LOCAL_PATH)/Makefile.sources

VK_ENTRYPOINTS_SCRIPT := $(MESA_PYTHON2) $(LOCAL_PATH)/vulkan/anv_entrypoints_gen.py

VK_EXTENSIONS_SCRIPT := $(MESA_PYTHON2) $(LOCAL_PATH)/vulkan/anv_extensions.py

VULKAN_COMMON_INCLUDES := \
	$(MESA_TOP)/src/mapi \
	$(MESA_TOP)/src/gallium/auxiliary \
	$(MESA_TOP)/src/gallium/include \
	$(MESA_TOP)/src/mesa \
	$(MESA_TOP)/src/vulkan/wsi \
	$(MESA_TOP)/src/vulkan/util \
	$(MESA_TOP)/src/intel \
	$(MESA_TOP)/include/drm-uapi \
	$(MESA_TOP)/src/intel/vulkan

# libmesa_anv_entrypoints with header and dummy.c
#
# This static library is built to pull entrypoints header
# for multiple gen specific build targets below. The c file
# is generated separately for libmesa_vulkan_common to avoid
# duplicate symbols when linking the anv libraries.

include $(CLEAR_VARS)
LOCAL_MODULE := libmesa_anv_entrypoints
LOCAL_MODULE_CLASS := STATIC_LIBRARIES

intermediates := $(call local-generated-sources-dir)

LOCAL_C_INCLUDES := \
	$(VULKAN_COMMON_INCLUDES)

LOCAL_GENERATED_SOURCES += $(intermediates)/vulkan/anv_entrypoints.h
LOCAL_GENERATED_SOURCES += $(intermediates)/vulkan/dummy.c

$(intermediates)/vulkan/dummy.c:
	@mkdir -p $(dir $@)
	@echo "Gen Dummy: $(PRIVATE_MODULE) <= $(notdir $(@))"
	$(hide) touch $@

$(intermediates)/vulkan/anv_entrypoints.h: $(intermediates)/vulkan/dummy.c
	$(VK_ENTRYPOINTS_SCRIPT) \
		--outdir $(dir $@) \
		--xml $(MESA_TOP)/src/vulkan/registry/vk.xml

LOCAL_EXPORT_C_INCLUDE_DIRS := \
        $(intermediates)

LOCAL_SHARED_LIBRARIES := libdrm

include $(MESA_COMMON_MK)
include $(BUILD_STATIC_LIBRARY)

ANV_INCLUDES := \
	$(VULKAN_COMMON_INCLUDES) \
	$(call generated-sources-dir-for,STATIC_LIBRARIES,libmesa_anv_entrypoints,,)/vulkan \
	$(call generated-sources-dir-for,STATIC_LIBRARIES,libmesa_nir,,)/nir \
	$(call generated-sources-dir-for,STATIC_LIBRARIES,libmesa_vulkan_util,,)/util

#
# libanv for gen7
#

include $(CLEAR_VARS)
LOCAL_MODULE := libmesa_anv_gen7
LOCAL_MODULE_CLASS := STATIC_LIBRARIES

LOCAL_SRC_FILES := $(VULKAN_GEN7_FILES)
LOCAL_CFLAGS := -DGEN_VERSIONx10=70

LOCAL_C_INCLUDES := $(ANV_INCLUDES)

LOCAL_WHOLE_STATIC_LIBRARIES := libmesa_anv_entrypoints libmesa_genxml

LOCAL_SHARED_LIBRARIES := libdrm

include $(MESA_COMMON_MK)
include $(BUILD_STATIC_LIBRARY)

#
# libanv for gen75
#

include $(CLEAR_VARS)
LOCAL_MODULE := libmesa_anv_gen75
LOCAL_MODULE_CLASS := STATIC_LIBRARIES

LOCAL_SRC_FILES := $(VULKAN_GEN75_FILES)
LOCAL_CFLAGS := -DGEN_VERSIONx10=75

LOCAL_C_INCLUDES := $(ANV_INCLUDES)

LOCAL_WHOLE_STATIC_LIBRARIES := libmesa_anv_entrypoints libmesa_genxml

LOCAL_SHARED_LIBRARIES := libdrm

include $(MESA_COMMON_MK)
include $(BUILD_STATIC_LIBRARY)

#
# libanv for gen8
#

include $(CLEAR_VARS)
LOCAL_MODULE := libmesa_anv_gen8
LOCAL_MODULE_CLASS := STATIC_LIBRARIES

LOCAL_SRC_FILES := $(VULKAN_GEN8_FILES)
LOCAL_CFLAGS := -DGEN_VERSIONx10=80

LOCAL_C_INCLUDES := $(ANV_INCLUDES)

LOCAL_WHOLE_STATIC_LIBRARIES := libmesa_anv_entrypoints libmesa_genxml

LOCAL_SHARED_LIBRARIES := libdrm

include $(MESA_COMMON_MK)
include $(BUILD_STATIC_LIBRARY)

#
# libanv for gen9
#

include $(CLEAR_VARS)
LOCAL_MODULE := libmesa_anv_gen9
LOCAL_MODULE_CLASS := STATIC_LIBRARIES

LOCAL_SRC_FILES := $(VULKAN_GEN9_FILES)
LOCAL_CFLAGS := -DGEN_VERSIONx10=90

LOCAL_C_INCLUDES := $(ANV_INCLUDES)

LOCAL_WHOLE_STATIC_LIBRARIES := libmesa_anv_entrypoints libmesa_genxml

LOCAL_SHARED_LIBRARIES := libdrm

include $(MESA_COMMON_MK)
include $(BUILD_STATIC_LIBRARY)

#
# libanv for gen10
#

include $(CLEAR_VARS)
LOCAL_MODULE := libmesa_anv_gen10
LOCAL_MODULE_CLASS := STATIC_LIBRARIES

LOCAL_SRC_FILES := $(VULKAN_GEN10_FILES)
LOCAL_CFLAGS := -DGEN_VERSIONx10=100

LOCAL_C_INCLUDES := $(ANV_INCLUDES)

LOCAL_WHOLE_STATIC_LIBRARIES := libmesa_anv_entrypoints libmesa_genxml

LOCAL_SHARED_LIBRARIES := libdrm

include $(MESA_COMMON_MK)
include $(BUILD_STATIC_LIBRARY)

#
# libmesa_vulkan_common
#

include $(CLEAR_VARS)
LOCAL_MODULE := libmesa_vulkan_common
LOCAL_MODULE_CLASS := STATIC_LIBRARIES

intermediates := $(call local-generated-sources-dir)

LOCAL_SRC_FILES := $(VULKAN_FILES)

LOCAL_C_INCLUDES := \
	$(ANV_INCLUDES) \
	$(MESA_TOP)/src/compiler

LOCAL_WHOLE_STATIC_LIBRARIES := \
	libmesa_anv_entrypoints \
	libmesa_genxml \
	libmesa_vulkan_util

# The rule generates both C and H files, but due to some strange
# reason generating the files once leads to link-time issues.
# Work around create them here as well - we're safe from race
# conditions since they are stored in another location.

LOCAL_GENERATED_SOURCES += $(intermediates)/vulkan/anv_entrypoints.c
LOCAL_GENERATED_SOURCES += $(intermediates)/vulkan/anv_extensions.c

$(intermediates)/vulkan/anv_entrypoints.c:
	@mkdir -p $(dir $@)
	$(VK_ENTRYPOINTS_SCRIPT) \
		--xml $(MESA_TOP)/src/vulkan/registry/vk.xml \
		--outdir $(dir $@)

$(intermediates)/vulkan/anv_extensions.c:
	@mkdir -p $(dir $@)
	$(VK_EXTENSIONS_SCRIPT) \
		--xml $(MESA_TOP)/src/vulkan/registry/vk.xml \
		--out $@

LOCAL_SHARED_LIBRARIES := libdrm

include $(MESA_COMMON_MK)
include $(BUILD_STATIC_LIBRARY)


#
# libvulkan_intel
#

include $(CLEAR_VARS)

LOCAL_MODULE := libvulkan_intel
LOCAL_MODULE_CLASS := SHARED_LIBRARIES

LOCAL_LDFLAGS += -Wl,--build-id=sha1

LOCAL_SRC_FILES := \
	$(VULKAN_GEM_FILES)

LOCAL_C_INCLUDES := \
	$(VULKAN_COMMON_INCLUDES) \
	$(call generated-sources-dir-for,STATIC_LIBRARIES,libmesa_anv_entrypoints,,)/vulkan

LOCAL_EXPORT_C_INCLUDE_DIRS := $(MESA_TOP)/src/intel/vulkan

LOCAL_WHOLE_STATIC_LIBRARIES := \
	libmesa_nir \
	libmesa_isl \
	libmesa_glsl \
	libmesa_util \
	libmesa_blorp \
	libmesa_compiler \
	libmesa_intel_common \
	libmesa_vulkan_common \
	libmesa_anv_gen7 \
	libmesa_anv_gen75 \
	libmesa_anv_gen8 \
	libmesa_anv_gen9 \
	libmesa_anv_gen10 \
	libmesa_intel_compiler \
	libmesa_anv_entrypoints

LOCAL_SHARED_LIBRARIES := libdrm libz

include $(MESA_COMMON_MK)
include $(BUILD_SHARED_LIBRARY)
