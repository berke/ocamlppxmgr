.PHONY: all compile clean test

OCAMLBUILD=ocamlbuild -package compiler-libs.common -package dynlink

all: test

compile:
	$(OCAMLBUILD) ocamlppxmgr.byte example_extension.cmo

test: compile
	./test.sh
	
clean:
	$(OCAMLBUILD) -clean
	rm -rf _tmp
