##############################################################
#
# AESD-ASSIGNMENTS
# modification: 27DEC2025, by Arnaud SIMO
# Works for builds root and qemu: 30DEC2025
##############################################################

AESD_ASSIGNMENTS_VERSION = e17d40f
AESD_ASSIGNMENTS_SITE =  git@github.com:simo-2021/valeo_tcp_server.git
AESD_ASSIGNMENTS_SITE_METHOD = git
AESD_ASSIGNMENTS_GIT_SUBMODULES = YES

define AESD_ASSIGNMENTS_BUILD_CMDS
	#$(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)/finder-app  all
	#$(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)/server  all
	
	# 2. Compile votre serveur ECU à la RACINE du dépôt $(@D)
	$(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)/ valeo_ivc_socket
endef

define AESD_ASSIGNMENTS_INSTALL_TARGET_CMDS
	# Créer le dossier de destination
	$(INSTALL) -d -m 0755 $(TARGET_DIR)/etc/finder-app/conf

	# Utiliser $(@D)/conf/* si le dossier est à la racine de votre dépôt
	# OU $(@D)/finder-app/conf/* s'il est dans finder-app
	#$(INSTALL) -m 0644 $(@D)/conf/* $(TARGET_DIR)/etc/finder-app/conf/

	# Installation du binaire
	$(INSTALL) -m 0755 $(@D)/valeo_ivc_socket $(TARGET_DIR)/usr/bin/
endef


$(eval $(generic-package))
