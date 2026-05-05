##############################################################
#
# AESD-ASSIGNMENTS
# Done: 02MAi26, by Arnaud SIMO
# Works for builds root and qemu
##############################################################

VALEO_ECU_VERSION  = d15fa4b
VALEO_ECU_SITE =  git@github.com:simo-2021/valeo_tcp_server.git
VALEO_ECU_SITE_METHOD = git
VALEO_ECU_GIT_SUBMODULES = YES

define VALEO_ECU_BUILD_CMDS
    $(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_LDFLAGS) -o \
    $(@D)/valeo_ivc_socket $(@D)/valeo_ivc_socket.c
endef

define VALEO_ECU_INSTALL_TARGET_CMDS
	    $(INSTALL) -D -m 0755 $(@D)/valeo_ivc_socket \
    $(TARGET_DIR)/usr/bin/valeo_ivc_socket
endef

$(eval $(generic-package))