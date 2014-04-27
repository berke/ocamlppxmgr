(* Example_extension *)

(* Modified from
 * http://whitequark.org/blog/2014/04/16/a-guide-to-extension-points-in-ocaml/
 *)

open Ast_mapper
open Ast_helper
open Asttypes
open Parsetree
open Longident
open Location

let getenv s = try Sys.getenv s with Not_found -> ""

let mapper argv =
  match argv with
  | prefix :: rest ->
    (
      Ppxmgr.debugf "My environment prefix is %S" prefix;
      (* Our getenv_mapper only overrides the handling of expressions in the
       * default mapper. *)
      { default_mapper with
        expr = fun mapper expr ->
          match expr with
          (* Is this an extension node? *)
          | { pexp_desc =
                Pexp_extension (
                  (* Should have name "getenv". *)
                  _ (*{ txt = t_pfx },*), (* No need to test for this - the
                  manager takes care of it! *)
                  (* Should have a single structure item, which is evaluation of a constant string. *)
                  PStr [{ pstr_desc =
                            Pstr_eval ({ pexp_loc  = loc;
                                         pexp_desc =
                                           Pexp_constant (Const_string (sym, None))}, _)}] )}
            ->
            (* Replace with a constant string with the value from the environment. *)
            Exp.constant ~loc (Const_string (getenv (prefix^sym), None))
          (* Delegate to the default mapper. *)
          | x -> default_mapper.expr mapper x;
      }
    )
  | _ -> invalid_arg "Missing environment prefix"

let _ =
  Ast_mapper.register "example_extension" mapper
