##############################################################
#
# AESD-ASSIGNMENTS
# modification: 27DEC2025, by Arnaud SIMO
# Works for builds root and qemu: 30DEC2025
##############################################################

AESD_ASSIGNMENTS_VERSION = 79789cb
AESD_ASSIGNMENTS_SITE =  git@github.com:simo-2021/valeo_tcp_server.git
AESD_ASSIGNMENTS_SITE_METHOD = git
AESD_ASSIGNMENTS_GIT_SUBMODULES = YES

define AESD_ASSIGNMENTS_BUILD_CMDS
	
	# 2. Compile votre serveur ECU à la RACINE du dépôt $(@D)
	$(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)/ all
endef

define AESD_ASSIGNMENTS_INSTALL_TARGET_CMDS


	# Installation du binaire
	$(INSTALL) -m 0755 $(@D)/valeo_ivc_socket $(TARGET_DIR)/usr/bin/
endef


$(eval $(generic-package))
