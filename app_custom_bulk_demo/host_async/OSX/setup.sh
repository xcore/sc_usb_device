#!/bin/sh

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:$dir/../libusb/OSX
chmod a+x $dir/bulktest
