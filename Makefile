SHELL		= /bin/sh
SPC		= $(null) $(null)

MAKE_ENVFILE	?= .env
ifneq ($(wildcard $(MAKE_ENVFILE)),)
# ifeq ($(MAKELEVEL),0)
# $(info '## Makefile using envfile: $(MAKE_ENVFILE)')
# endif
include $(MAKE_ENVFILE)
endif

#//
define UBUNTU_VER_MAJOR =		   # e.g. "18"
$(firstword $(subst .,$(SPC),$(UBUNTU_VERSION)))
endef

define BOX_VARIANT_STR =		   # e.g. "-server"
$(if $(BOX_VARIANT),-$(BOX_VARIANT))
endef

define BOX_VM_NAME =			   # e.g. "ubuntu1804-server"
ubuntu$(subst $(SPC),,$(wordlist 1,2,$(subst .,$(SPC),$(UBUNTU_VERSION))))$(BOX_VARIANT_STR)
endef

PACKER_DIR	?= .
PACKER_CONF_DIR	?=
PACKER_HTTP_DIR	?=

PACKER_LOG	?=
PACKER_LOG_PATH	?=
export PACKER_LOG PACKER_LOG_PATH

BOX_OUTPUT_DIR	= box
BOX_FILE_BASE	= virtualbox-$(BOX_VM_NAME)
BOX_FILE	= $(BOX_OUTPUT_DIR)/$(BOX_FILE_BASE).box

BOX_NAME	= $(if $(BOX_PREFIX),$(BOX_PREFIX)/)$(BOX_VM_NAME)-$(UBUNTU_VERSION).$(or $(BOX_RELEASE),wip)

define PACKER_BUILD_FLAGS =
-color=false
endef
PACKER_BUILD	= packer build $(PACKER_BUILD_FLAGS)

vpath %.json $(if $(PACKER_CONF_DIR),$(PACKER_CONF_DIR):)$(PACKER_DIR)/ubuntu
vpath %.cfg $(if $(PACKER_HTTP_DIR),$(PACKER_HTTP_DIR):)$(PACKER_DIR)/http

define PACKER_CONFIGS =
ubuntu$(UBUNTU_VER_MAJOR).json
$(UBUNTU_VERSION).json
$(if $(BOX_VARIANT_STR),$(UBUNTU_VERSION)$(BOX_VARIANT_STR).json)
$(null)
endef

define PACKER_VARS =
script_directory=$(PACKER_DIR)/script
http_directory=$(if $(PACKER_HTTP_DIR),$(PACKER_HTTP_DIR),$(PACKER_DIR)/http)
output_directory=$(BOX_OUTPUT_DIR)
preseed=preseed-ubuntu$(BOX_VARIANT_STR).cfg
endef

define VAGRANT_BOX_NAME =
$(BOX_NAME)
endef
export VAGRANT_BOX_NAME

define VAGRANT_VM_NAME =		   # e.g. "u18box"
u$(UBUNTU_VER_MAJOR)box
endef
export VAGRANT_VM_NAME

#------------------------------------------------------------------------
all: help

include Makefile.help
help:; @echo "$$HELPTEXT"

clean:
	find . -name '*~' -delete
	rm -rf box packer_cache

cleanall: clean;

.PHONY: all help clean cleanall

#------------------------------------------------------------------------
help+% box.build+% box.add+% box.name+% box.file+% Vagrantfile+%:
	@$(MAKE) --no-print-directory $(@:%+$*=%) BOX_VARIANT=$*

box.build: $(BOX_FILE)

$(BOX_FILE): $(strip $(PACKER_CONFIGS)) preseed-ubuntu$(BOX_VARIANT_STR).cfg $(ENVFILE)
	@echo "=> $@"
	@( set -x; \
	   $(PACKER_BUILD) \
	     $(addprefix --var-file$(SPC),$(filter %.json,$(wordlist 2,$(words $^),$^))) \
	     $(addprefix --var$(SPC),$(strip $(PACKER_VARS))) \
	     $(firstword $^) \
	)

box.add: $(BOX_FILE)
	@echo "=> $@"
	vagrant box add $(BOX_FILE) --name $(BOX_NAME) --force

box.name:; @echo $(BOX_NAME)
box.file:; @echo $(BOX_FILE)

.PHONY: box.build box.add box.name box.file

#------------------------------------------------------------------------
# Usage:
#   VAGRANT_CWD=.. make Vagrantfile
#
Vagrantfile: $(if $(VAGRANT_CWD),$(VAGRANT_CWD)/)Vagrantfile.template/Vagrantfile$(BOX_VARIANT_STR)
	cat $< | envsubst >$(if $(VAGRANT_CWD),$(VAGRANT_CWD)/)$@

.PHONY: Vagrantfile

# Local Variables:
# fill-column: 70
# End:
