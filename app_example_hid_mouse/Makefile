# The TARGET variable determines what target system the application is 
# compiled for. It either refers to an XN file in the source directories
# or a valid argument for the --target option when compiling.


# This example runs on the XS-L1 usb audio board. It doesn't use any of
# the audio functionality and just uses the USB functionality of the board
#TARGET = L1_AUDIO
#TARGET = XDK
TARGET= xp_skc_su1

#Use G version of XUD
#export XUD_G=1


# The APP_NAME variable determines the name of the final .xe file. It should
# not include the .xe postfix. If left blank the name will default to 
# the project name

APP_NAME = app_example_usb_hid

# The flags passed to xcc when building the application
# You can also set the following to override flags for a particular language:
#
#    XCC_XC_FLAGS, XCC_C_FLAGS, XCC_ASM_FLAGS, XCC_CPP_FLAGS
#
# If the variable XCC_MAP_FLAGS is set it overrides the flags passed to 
# xcc for the final link (mapping) stage.

BUILD_FLAGS = -Wall -O2 -report -fsubword-select -DUSB_CORE=0 -DTEST_MODE_SUPPORT -DARCH_S

# The USED_MODULES variable lists other module used by the application. 

# Use ADC
XCC_FLAGS_adc = $(BUILD_FLAGS) -DADC=1
INCLUDE_ONLY_IN_adc = 

#Don't use ADC
XCC_FLAGS_noadc = $(BUILD_FLAGS)
INCLUDE_ONLY_IN_noadc = 

USED_MODULES = module_usb_shared module_usb_device module_xud module_u_series_support module_logging module_xassert

MODULE_LIBRARIES = xud_s

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
