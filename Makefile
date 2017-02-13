VNFD_DIRS:= server_vnfd tse_vnfd pts_vnfd cc_vnfd
NSD_DIRS:= tse_nsd cc_nsd

PKG_TAR := $(addprefix build/,$(addsuffix .tar.gz, $(VNFD_DIRS) $(NSD_DIRS) ))
PKG_CHECKSUMS:= $(addsuffix /checksums.txt, $(VNFD_DIRS) $(NSD_DIRS) )
PKG_YAML:= $(addsuffix .yaml, $(VNFD_DIRS) $(NSD_DIRS) )

VNFD_CLOUD_INIT:= $(addprefix build/, $(addsuffix /cloud_init/cloud_init.cfg,$(VNFD_DIRS)))

server_vnfd_IMAGE ?= "Ubuntu 16.04.1 LTS - Xenial Xerus - 64-bit - Cloud Based Image"
cc_vnfd_IMAGE ?= "Ubuntu 16.04.1 LTS - Xenial Xerus - 64-bit - Cloud Based Image"
tse_vnfd_IMAGE    ?= TSE_1.00.00-0075_x86_64_el7
pts_vnfd_IMAGE    ?= PTS_7.40.00-0309_x86_64_el7
LICENSE_SERVER    ?= license.sandvine.rocks

all:  $(VNFD_CLOUD_INIT) build_dir
	$(MAKE) $(PKG_TAR)

BUILD_TARGET = build/$(TARGET)

%.tar.gz: TARGET=$(notdir $*)

%.tar.gz:
	@echo "building $(TARGET)"
	@cp -R $(TARGET) build/.
	@cat $(BUILD_TARGET)/template/$(TARGET).yaml | sed -e 's/vnfd:image:.*/vnfd:image: $($(TARGET)_IMAGE)/g' > $(BUILD_TARGET)/$(TARGET).yaml
	@cd $(BUILD_TARGET); find . -type f -not -path "*/template" -not -path "*/template/*" | xargs md5sum | sed -e 's/\.\///g' > checksums.txt; cd ..
	@tar --exclude=template -cvf build/$(TARGET).tar -C build $(TARGET)/ > /dev/null
	@gzip $(BUILD_TARGET).tar

$(VNFD_CLOUD_INIT): VNFD_DIR=$(shell basename $(shell dirname $(shell dirname $@)))

$(VNFD_CLOUD_INIT):
	@mkdir -p build/$(VNFD_DIR)/cloud_init
	@cat $(VNFD_DIR)/template/cloud_init.cfg | sed -e 's/license_server_primary=.*/license_server_primary="$(LICENSE_SERVER)"/g' > $@

%.yaml.clean:
	@rm -f $*/$*.yaml

build_dir:
	@mkdir -p build

.PHONY: build_dir

clean:
	@rm -rf build
