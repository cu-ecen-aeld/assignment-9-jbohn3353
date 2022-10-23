
##############################################################
#
# LDD
#
##############################################################

#TODO: Fill up the contents below in order to reference your assignment 3 git contents
LDD_VERSION = '6c263d312ca0770b3caf999e0b3588a0c3dcb0c8'
# Note: Be sure to reference the *ssh* repository URL here (not https) to work properly
# with ssh keys and the automated build/test system.
# Your site should start with git@github.com:
LDD_SITE = 'git@github.com:cu-ecen-aeld/assignment-7-jbohn3353.git'
LDD_SITE_METHOD = git
LDD_GIT_SUBMODULES = YES

LDD_MODULE_SUBDIRS += misc-modules
LDD_MODULE_SUBDIRS += scull

define LDD_CMDS
	$(MAKE)
endef

# TODO copy .ko modules to target FS
define LDD_INSTALL_TARGET_CMDS
	$(INSTALL) -d 0755 $(TARGET_DIR)/lib/modules/5.15.18/extra/
	$(INSTALL) -m 0755 $(@D)/misc-modules/*.ko $(TARGET_DIR)/lib/modules/5.15.18/extra/
	$(INSTALL) -m 0755 $(@D)/scull/scull.ko $(TARGET_DIR)/lib/modules/5.15.18/extra/
endef

$(eval $(kernel-module))
$(eval $(generic-package))
