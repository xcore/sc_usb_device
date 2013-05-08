# The TARGET variable determines what target system the application is 
# compiled for. It either refers to an XN file in the source directories
# or a valid argument for the --target option when compiling.



# The APP_NAME variable determines the name of the final .xe file. It should
# not include the .xe postfix. If left blank the name will default to 
# the project name
APP_NAME = app_example_usb_custom_bulk

# The flags passed to xcc when building the application
# You can also set the following to override flags for a particular language:
#
#    XCC_XC_FLAGS, XCC_C_FLAGS, XCC_ASM_FLAGS, XCC_CPP_FLAGS
#
# If the variable XCC_MAP_FLAGS is set it overrides the flags passed to 
# xcc for the final link (mapping) stage.

BUILD_FLAGS = -Wall -O3 -report -fsubword-select -DTEST_MODE_SUPPORT

#U series
XCC_FLAGS_u = $(BUILD_FLAGS)
INCLUDE_ONLY_IN_u = 

#L series 
XCC_FLAGS_l = $(BUILD_FLAGS) -DL_SERIES
INCLUDE_ONLY_IN_l = 
:
# The USED_MODULES variable lists other module used by the application. 
USED_MODULES = module_usb_shared module_usb_device module_xud module_u_series_support module_logging module_xassert

ifeq ($(CONFIG), u) 
	TARGET= xp_skc_su1.xn 
	MODULE_LIBRARIES = xud_u 
endif

ifeq ($(CONFIG), l) 
	TARGET = xr-usb-audio-2.0.xn 
	MODULE_LIBRARIES = xud_l 
endif

#=============================================================================
#=============================================================================
# The following part of the Makefile includes the common build infrastructure
# for compiling XMOS applications. You should not need to edit below here.

XMOS_MAKE_PATH ?= ../..
ifneq ($(wildcard $(XMOS_MAKE_PATH)/xcommon/module_xcommon/build/Makefile.common),)
include $(XMOS_MAKE_PATH)/xcommon/module_xcommon/build/Makefile.common
else
include ../module_xcommon/build/Makefile.common
endif


