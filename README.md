ocamlppxmgr - WORK IN PROGRESS
==============================
Berke Durak <berke.durak@gmail.com

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

Dependncies
-----------

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
