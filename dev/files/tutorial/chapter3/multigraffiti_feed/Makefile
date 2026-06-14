
APP_NAME := graffiti
SERVER_PACKAGE := cairo, unix
CLIENT_PACKAGE :=

SERVER_FILES = common.ml server.ml feed.ml ${wildcard *.eliom}
CLIENT_FILES = common.ml client.ml ${wildcard *.eliom}

PORT := 8080

OCLOSURE := YES

###

all: local byte opt conf

LIBDIR := local/var/www/lib
JSDIR  := local/var/www/static

include Makefile.common

distclean::
	-rm -rf css/closure
	-rm -rf local
	-rm -f graffiti.conf

####

DIRS = local/var/lib/ocsidbm local/var/run local/var/log \
       local/var/www/static local/var/www/lib local/etc \
       local/var/www/static/graffiti_saved

local: ${DIRS} local/var/www/static/css local/var/www/static/images css/closure

local/var/www/static/css:
	ln -fs $(shell pwd)/css local/var/www/static/css

local/var/www/static/images:
	ln -fs $(shell pwd)/images local/var/www/static/images

css/closure:
	ln -fs $(shell ocamlfind query oclosure)/closure/goog/css/ css/closure

${DIRS}:
	mkdir -p $@

conf: graffiti.conf

graffiti.conf: graffiti.conf.in
	sed -e "s|%%SRC%%|$(shell pwd)|" \
	    -e "s|%%LIBDIR%%|${LIBDIR}|" \
	    -e "s|%%JSDIR%%|${JSDIR}|" \
	    -e "s|%%PORT%%|${PORT}|" \
	    $< > $@

run.local: graffiti.conf
	ocsigenserver -c graffiti.conf

run.opt.local: graffiti.conf
	ocsigenserver.opt -c graffiti.conf

####

install::
	install -d -m 775 ${INSTALL_USER} ${INSTALL_DIR}/static/css
	install -m 664 ${INSTALL_USER} css/*.css ${INSTALL_DIR}/static/css
	cd $(shell ocamlfind query oclosure)/closure/goog/css/ && \
	  find -type f -exec install -D -m 664 {} ${INSTALL_DIR}/static/css/closure/{} \;
