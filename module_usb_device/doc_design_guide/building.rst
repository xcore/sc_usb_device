
.. _usb_device_building_for_l_series:

Building for L-Series
---------------------

**Note:** ``module_usb_device`` and ``module_xud`` upon which it depends both support
both U-Series and L-Series devices, but the xSOFTip explorer will only perform resource
estimation with the U-Series library.

**Note:** Also, tools before the 13.0 release do not support automatically changing a
target library. Therefore, if using xTIMEcomposer pre-13.0 the ``Makefile`` generated will
have to be modified in order to compile for an L-Series device. Open the ``Makefile``
and add the line ``MODULE_LIBRARIES = xud_l``.

