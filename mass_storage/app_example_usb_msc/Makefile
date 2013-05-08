#TARGET = xvbgx-1-l2
#TARGET = L1_AUDIO
#TARGET = XDK
#TARGET = usb_audio_s1
TARGET = xp_skc_su1

APP_NAME = 

# The flags passed to xcc when building the application
# You can also set the following to override flags for a particular language:
#
#    XCC_XC_FLAGS, XCC_C_FLAGS, XCC_ASM_FLAGS, XCC_CPP_FLAGS
#
# If the variable XCC_MAP_FLAGS is set it overrides the flags passed to 
# xcc for the final link (mapping) stage.

XCC_FLAGS = -Wall -O3 -report -fsubword-select -DUSB_CORE=0 -DTEST_MODE_SUPPORT -DARCH_L -DARCH_S -g -lflash
#XCC_FLAGS = -Wall -O2 -report -fsubword-select -DUSB_CORE=1 -DXDK

# The USED_MODULES variable lists other module used by the application. 

# USED_MODULES = module_usb_shared module_xud module_sdcard4bit module_FatFs module_mass_storage
USED_MODULES = module_usb_shared module_xud module_mass_storage

MODULE_LIBRARIES = xud_s

#=============================================================================
# The following part of the Makefile includes the common build infrastructure
# for compiling XMOS applications. You should not need to edit below here.


# Use the main Makefile from module_xmos_common
XMOS_MAKE_DIR ?= ../..
include $(XMOS_MAKE_DIR)/xcommon/module_xcommon/build/Makefile.common
