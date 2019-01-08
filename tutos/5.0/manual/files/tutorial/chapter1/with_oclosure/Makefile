
## Sample Makefile for eliom application.

APP_NAME := graffiti

## Packages required to build the server part of the application

SERVER_PACKAGES := cairo

## Packages to be linked in the client part

CLIENT_PACKAGES := oclosure

## Source files for the server part

SERVER_FILES := ${wildcard *.eliom}

## Source files for the client part

CLIENT_FILES := ${wildcard *.eliom}

## Required binaries

ELIOMC       := eliomc
ELIOMOPT     := eliomopt
ELIOMDEP     := eliomdep
JS_OF_ELIOM  := js_of_eliom
OCLOSURE_REQ := oclosure_req

## Where to put intermediate object files.
## - ELIOM_{SERVER,CLIENT}_DIR must be distinct
## - ELIOM_CLIENT_DIR mustn't be the local dir.
## - ELIOM_SERVER_DIR could be ".", but you need to
##   remove it from the "clean" rules...

export ELIOM_SERVER_DIR := _server
export ELIOM_CLIENT_DIR := _client
export ELIOM_TYPE_DIR   := ${ELIOM_SERVER_DIR}

#####################################

all: byte opt
byte:: ${APP_NAME}.cma ${APP_NAME}.js ${APP_NAME}_oclosure.js
opt:: ${APP_NAME}.cmxs ${APP_NAME}.js ${APP_NAME}_oclosure.js

#### Server side compilation #######

SERVER_INC  := ${addprefix -package ,${SERVER_PACKAGES}}

SERVER_OBJS := $(patsubst %.eliom,${ELIOM_SERVER_DIR}/%.cmo, ${SERVER_FILES})
SERVER_OBJS := $(patsubst %.ml,${ELIOM_SERVER_DIR}/%.cmo, ${SERVER_OBJS})

${APP_NAME}.cma: ${SERVER_OBJS}
	${ELIOMC} -a -o $@ $^
${APP_NAME}.cmxa: ${SERVER_OBJS:.cmo=.cmx}
	${ELIOMOPT} -a -o $@ $^

${ELIOM_TYPE_DIR}/%.type_mli: %.eliom
	${ELIOMC} -infer ${SERVER_INC} $<

${ELIOM_SERVER_DIR}/%.cmi: %.mli
	${ELIOMC} -c ${SERVER_INC} $<

${ELIOM_SERVER_DIR}/%.cmo: %.ml
	${ELIOMC} -c ${SERVER_INC} $<
${ELIOM_SERVER_DIR}/%.cmo: %.eliom
	${ELIOMC} -c -noinfer ${SERVER_INC} $<

${ELIOM_SERVER_DIR}/%.cmx: %.ml
	${ELIOMOPT} -c ${SERVER_INC} $<
${ELIOM_SERVER_DIR}/%.cmx: %.eliom
	${ELIOMOPT} -c -noinfer ${SERVER_INC} $<

%.cmxs: %.cmxa
	$(ELIOMOPT) -shared -linkall -o $@ $<

##### Client side compilation ####

CLIENT_LIBS := ${addprefix -package ,${CLIENT_PACKAGES}}
CLIENT_INC  := ${addprefix -package ,${CLIENT_PACKAGES}}

CLIENT_OBJS := $(patsubst %.eliom,${ELIOM_CLIENT_DIR}/%.cmo, ${CLIENT_FILES})
CLIENT_OBJS := $(patsubst %.ml,${ELIOM_CLIENT_DIR}/%.cmo, ${CLIENT_OBJS})

${APP_NAME}.js: ${CLIENT_OBJS}
	${JS_OF_ELIOM} -o $@ ${CLIENT_LIBS} $^

${ELIOM_CLIENT_DIR}/%.cmi: %.mli
	${JS_OF_ELIOM} -c ${CLIENT_INC} $<

${ELIOM_CLIENT_DIR}/%.cmo: %.eliom
	${JS_OF_ELIOM} -c ${CLIENT_INC} $<
${ELIOM_CLIENT_DIR}/%.cmo: %.ml
	${JS_OF_ELIOM} -c ${CLIENT_INC} $<

############

## Clean up

clean:
	-rm -f *.cm[ioax] *.cmxa *.cmxs *.o *.a *.annot
	-rm -f *.type_mli
	-rm -f ${APP_NAME}.js
	-rm -rf ${ELIOM_CLIENT_DIR} ${ELIOM_SERVER_DIR}
	-rm -f $(APP_NAME)_oclosure.js

distclean: clean
	-rm -f *~ \#* .\#*
	-rm -f .depend

## Dependencies

depend: .depend
.depend: ${SERVER_FILES} ${CLIENT_FILES}
	$(ELIOMDEP) -server ${SERVER_INC} ${SERVER_FILES} > .depend
	$(ELIOMDEP) -client ${CLIENT_INC} ${CLIENT_FILES} >> .depend

## Warning: Dependencies towards *.eliom are not handled by eliomdep yet.
## Add manually dependencies between cmo and cmx files here,
## for example:
## oneeliomfile.cmo: anothereliomfile.cmo
## oneeliomfile.cmx: anothereliomfile.cmx

include .depend

## installation #########

STATICDIR      := /tmp/static

$(STATICDIR):
	mkdir -p $@

install: all $(STATICDIR)
	cp $(APP_NAME)_oclosure.js $(STATICDIR)/$(APP_NAME)_oclosure.js
	cp $(APP_NAME).js $(STATICDIR)/$(APP_NAME).js

## oclosure #############

OCAML          := ocaml
OCAMLFIND      := ocamlfind
OCLOSUREDIR    := $(shell ${OCAMLFIND} query oclosure)

$(APP_NAME)_oclosure.js: $(APP_NAME).js
	${OCLOSURE_REQ} $^
