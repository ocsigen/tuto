
TUTORIAL_VERSION ?= $(error "Specify a version through TUTORIAL_VERSION")
TUTORIAL_DIR ?= /var/www/data/manualwiki/tutorial
VERSION_DIR = $(TUTORIAL_DIR)/$(TUTORIAL_VERSION)
USER = www-data
GENERATE_TEMPLATE=./install_template.sh

show-help:
	@echo "Usage:\n"\
	"TUTORIAL_VERSION=x.y make install\n"\
	"The target directory may be passed by TUTORIAL_DIR."

install:
	@echo ">> Installing tutorial version $(TUTORIAL_VERSION) to $(TUTORIAL_DIR)"
	sudo -u $(USER) rm -rf $(VERSION_DIR)
	sudo -u $(USER) mkdir -p $(VERSION_DIR)
	sudo -u $(USER) cp -r src $(VERSION_DIR)/
	sudo -u $(USER) cp -r files $(VERSION_DIR)/
	(cd $(VERSION_DIR)/files; sudo -u $(USER) tar cfvz tutorial.tar.gz tutorial)

set-stable:
	(cd $(TUTORIAL_DIR); sudo -u $(USER) ln -sf -T $(TUTORIAL_VERSION) stable)

local:
	$(GENERATE_TEMPLATE)
	quickdop -f $(DOC) _doc -t json -c how.json -viu
