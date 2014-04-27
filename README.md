ocamlppxmgr - WORK IN PROGRESS
==============================
Berke Durak <berke.durak@gmail.com>

WARNING
-------

This is a proof-of-concept release.  Only expressions are implemented.

Description
------------

The powerful new PPX syntax extension interface is expected to engender a
proliferation of extensions, turning our beautiful language into an ugly
tower-of-Babel mess.

ocamlppxmgr is a meta syntax extension that dynamically loads individual
extensions and makes sure they play ball together.  It also provides syntax
extension management using annotations.

Rules
-----

* All extensions must be explicitly enabled in each file.  This is a feature
  that forces the source code to explicitly refer to a syntax extension.  The
  meaning of a .ml file can thus be fully determined, provided all references to
  syntax extensions can be resolves.
* The developer only needs to ensure that all required extensions are specified
  in the build flags.  The manager should probably be modified to allow loading
  of extensions from the source files themselves.
* The manager handles enabling, disabling and aliasing of extensions.  Thus if
  you want to use let%t instead of let%lwt you can just define an alias.
  Aliases can be changed throughout the source file.
* Extensions can only touch toplevel AST nodes that have an attribute with a
  matching name.  No more "I'll silently mess with your AST just because I
  happen to be loaded"!

Directives
----------

* ("enable","NAME") - Enable extension "NAME" for the rest of the source
* ("disable","NAME") - Disable extension "NAME" for the rest of the source
* ("alias","NAME1","NAME2") - Create a new alias "NAME1" for "NAME"
* ("hide","NAME") - Hide "NAME" from current extensions
* ("rename","NAME") - Change the attribute name for ocamlppxmgr itself to "NAME"
* ("control","off") - Disable ocamlppxmgr itself
* ("control","on") - Enable ocamlppxmgr itself

Invocation
----------

* For ocamlppxmgr itself, the arguments are:
  ocamlppxmgr.byte \
    -path /path/to/my/extensions \
    ext1 -arg ext1arg1 -ext ext1arg2 ... -ext ext1argn1 \
    ext2 -arg ext2arg1 -ext ext2arg2 ... -ext ext2argn2 \
    ...
* To see it in action, use: ocamlc -ppx "..." -dsource -c foo.ml

Dependencies
------------

* Ocaml with recent compiler libs 4.02.0dev+trunk

Usage
-----

A test script and foo.ml file is included.  Look at it.

  opam switch 4.02.0dev+trunk
  make

Credits & references
--------------------

* People on #ocaml / irc.freenode.org
* whitequark: http://whitequark.org/blog/2014/04/16/a-guide-to-extension-points-in-ocaml/
