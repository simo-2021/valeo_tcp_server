##############################################################
#
# AESD-ASSIGNMENTS
# modification: 27DEC2025, by Arnaud SIMO
# Works for builds root and qemu: 30DEC2025
##############################################################

AESD_ASSIGNMENTS_VERSION = 7dcd433
AESD_ASSIGNMENTS_SITE =  git@github.com:simo-2021/valeo_tcp_server.git
AESD_ASSIGNMENTS_SITE_METHOD = git
AESD_ASSIGNMENTS_GIT_SUBMODULES = YES

define VALEO_IVC_SOCKET_BUILD_CMDS
    $(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_LDFLAGS) -o \
    $(@D)/valeo_ivc_socket $(@D)/valeo_ivc_socket.c
endef

define VALEO_IVC_SOCKET_INSTALL_TARGET_CMDS
    $(INSTALL) -D -m 0755 $(@D)/valeo_ivc_socket \
    $(TARGET_DIR)/usr/bin/valeo_ivc_socket
endef

