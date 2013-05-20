# The TARGET variable determines what target system the application is 
# compiled for. It either refers to an XN file in the source directories
# or a valid argument for the --target option when compiling.



# The APP_NAME variable determines the name of the final .xe file. It should
# not include the .xe postfix. If left blank the name will default to 
# the project name
APP_NAME = app_example_hid_mouse

# The flags passed to xcc when building the application
# You can also set the following to override flags for a particular language:
#
#    XCC_XC_FLAGS, XCC_C_FLAGS, XCC_ASM_FLAGS, XCC_CPP_FLAGS
#
# If the variable XCC_MAP_FLAGS is set it overrides the flags passed to 
# xcc for the final link (mapping) stage.

BUILD_FLAGS = -Wall -O3 -report -fsubword-select -DTEST_MODE_SUPPORT

# U series using ADC
XCC_FLAGS_u_adc = $(BUILD_FLAGS) -DADC=1 -DXUD_ON_U_SERIES
INCLUDE_ONLY_IN_u_adc = 

#U series not using ADC
XCC_FLAGS_u_noadc = $(BUILD_FLAGS) -DXUD_ON_U_SERIES
INCLUDE_ONLY_IN_u_noadc = 

# U16 series using ADC
XCC_FLAGS_u16_adc = $(BUILD_FLAGS) -DADC=1 -DXUD_ON_U_SERIES
INCLUDE_ONLY_IN_u_adc = 

# U16 series not using ADC
XCC_FLAGS_u16_noadc = $(BUILD_FLAGS) -DXUD_ON_U_SERIES
INCLUDE_ONLY_IN_u_noadc = 

# L series not using ADC (it has no ADC)
XCC_FLAGS_l_noadc = $(BUILD_FLAGS) -DXUD_ON_L_SERIES
INCLUDE_ONLY_IN_l_noadc = 

# The USED_MODULES variable lists other module used by the application. 
USED_MODULES = module_usb_shared module_usb_device module_xud module_u_series_support module_logging module_xassert

ifeq ($(CONFIG), u_adc) 
	TARGET= xp-skc-su1.xn 
	MODULE_LIBRARIES = xud_u 
endif

ifeq ($(CONFIG), u_noadc) 
	TARGET= xp-skc-su1.xn 
	MODULE_LIBRARIES = xud_u 
endif

ifeq ($(CONFIG), l_noadc) 
	TARGET = xr-usb-audio-2.0.xn 
	MODULE_LIBRARIES = xud_l 
endif

ifeq ($(CONFIG), u16_adc) 
	TARGET = xp-skc-u16.xn 
	MODULE_LIBRARIES = xud_u 
endif

ifeq ($(CONFIG), u16_noadc) 
	TARGET = xp-skc-u16.xn
	MODULE_LIBRARIES = xud_u 
endif

#=============================================================================
# The following part of the Makefile includes the common build infrastructure
# for compiling XMOS applications. You should not need to edit below here.

# Use the main Makefile from module_xmos_common
XMOS_MAKE_DIR ?= ../..

#=============================================================================
# The following part of the Makefile includes the common build infrastructure
# for compiling XMOS applications. You should not need to edit below here.
XMOS_MAKE_PATH ?= ../..
include $(XMOS_MAKE_PATH)/xcommon/module_xcommon/build/Makefile.common
