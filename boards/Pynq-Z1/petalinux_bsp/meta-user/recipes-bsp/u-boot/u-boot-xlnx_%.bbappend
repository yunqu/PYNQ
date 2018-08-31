SRC_URI_append = " file://platform-top.h"
SRC_URI += " file://0001-add-pynqz1-support.patch"
SRC_URI += " file://ethernet_spi.cfg"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
