# The TARGET variable determines what target system the application is 
# compiled for. It either refers to an XN file in the source directories
# or a valid argument for the --target option when compiling.


# The APP_NAME variable determines the name of the final .xe file. It should
# not include the .xe postfix. If left blank the name will default to 
# the project name
APP_NAME = app_hid_mouse_demo

# The flags passed to xcc when building the application
# You can also set the following to override flags for a particular language:
#
#    XCC_XC_FLAGS, XCC_C_FLAGS, XCC_ASM_FLAGS, XCC_CPP_FLAGS
#
# If the variable XCC_MAP_FLAGS is set it overrides the flags passed to 
# xcc for the final link (mapping) stage.

BUILD_FLAGS = -Wall -O3 -report -fsubword-select -DTEST_MODE_SUPPORT -Xmapper --wno226

# U series using ADC
XCC_FLAGS_u8_adc = $(BUILD_FLAGS) -DADC=1 -DUSE_XSCOPE=1 -fxscope
INCLUDE_ONLY_IN_u8_adc = 

#U series not using ADC
XCC_FLAGS_u8_noadc = $(BUILD_FLAGS) -DUSE_XSCOPE=1 -fxscope 
INCLUDE_ONLY_IN_u8_noadc = 

# U16 series using ADC
XCC_FLAGS_u16_adc = $(BUILD_FLAGS) -DADC=1 -DU16=1 -DUSE_XSCOPE=1 -fxscope 
INCLUDE_ONLY_IN_u16_adc = 

# U16 series not using ADC
XCC_FLAGS_u16_noadc = $(BUILD_FLAGS) -DU16=1 -DUSE_XSCOPE=1 -fxscope 
INCLUDE_ONLY_IN_u16_noadc = 

# L8 series not using ADC (it has no ADC)
XCC_FLAGS_l8_noadc = $(BUILD_FLAGS) -DXUD_SERIES_SUPPORT=2
INCLUDE_ONLY_IN_l8_noadc = 

# L16 series not using ADC (it has no ADC)
XCC_FLAGS_l16_noadc = $(BUILD_FLAGS) -DXUD_SERIES_SUPPORT=2
INCLUDE_ONLY_IN_l16_noadc = 

# The USED_MODULES variable lists other module used by the application. 
USED_MODULES = module_usb_shared module_usb_device module_xud module_usb_tile_support module_logging

ifeq ($(CONFIG), u8_adc) 
	TARGET= xp-skc-su1.xn 
	MODULE_LIBRARIES = xud_u 
endif

ifeq ($(CONFIG), u8_noadc) 
	TARGET= xp-skc-su1.xn 
	MODULE_LIBRARIES = xud_u 
endif

ifeq ($(CONFIG), u16_adc) 
	TARGET = xp-skc-u16.xn 
	MODULE_LIBRARIES = xud_u 
endif

ifeq ($(CONFIG), u16_noadc) 
	TARGET = xp-skc-u16.xn
	MODULE_LIBRARIES = xud_u 
endif

ifeq ($(CONFIG), l8_noadc) 
	TARGET = xr-usb-audio-2.0.xn 
	MODULE_LIBRARIES = xud_l 
endif

ifeq ($(CONFIG), l16_noadc) 
	TARGET = xr-usb-audio-2.0-mc.xn 
	MODULE_LIBRARIES = xud_l 
endif


#=============================================================================
# The following part of the Makefile includes the common build infrastructure
# for compiling XMOS applications. You should not need to edit below here.

XMOS_MAKE_PATH ?= ../..
include $(XMOS_MAKE_PATH)/xcommon/module_xcommon/build/Makefile.common
