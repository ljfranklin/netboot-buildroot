################################################################################
#
# pxeserver-installer
#
################################################################################

PXESERVER_INSTALLER_LICENSE = MIT

define PXESERVER_INSTALLER_INSTALL_INIT_SYSV
	$(INSTALL) -m 0755 -D $(PXESERVER_INSTALLER_PKGDIR)/S99writeimgandreboot \
		$(TARGET_DIR)/etc/init.d/S99writeimgandreboot
endef

$(eval $(generic-package))
