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

define AESD_ASSIGNMENTS_BUILD_CMDS
	# On force un clean dans votre dépôt pour supprimer tout binaire x86 résiduel
	$(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)/ clean
	# On compile avec le compilateur ARM (TARGET_CC)
	$(MAKE) $(TARGET_CONFIGURE_OPTS) CC="$(TARGET_CC)" -C $(@D)/ all
endef


define AESD_ASSIGNMENTS_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0755 $(@D)/valeo_ivc_socket $(TARGET_DIR)/usr/bin/
endef

