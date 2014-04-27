#!/bin/sh

mkdir -p _tmp
cd _tmp
MY_PREFIX_USER=grandma \
ocamlc -ppx "../ocamlppxmgr.byte \
  -path ../_build example_extension \
  -arg MY_PREFIX_" -dsource -c foo.ml
