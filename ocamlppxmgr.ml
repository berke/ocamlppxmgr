(* Ocamlppxmgr
 
   Author: Berke Durak
*)

open Ast_mapper
open Ast_helper
open Asttypes
open Parsetree
open Longident
open Location
open Ppxmgr

module SM = Map.Make(String)

type extension =
  {
            ext_func    : string list -> Ast_mapper.mapper;
            ext_args    : string list;
    mutable ext_mapper  : Ast_mapper.mapper option;
    mutable ext_enabled : bool;
  }

let extensions : extension SM.t ref = ref SM.empty

let mapper ext name =
  let pfx = ref name in
  let enabled = ref true in
  let get_mapper x =
    match x.ext_mapper with
    | Some m -> m
    | None ->
        let m = x.ext_func x.ext_args in
        x.ext_mapper <- Some m;
        m
  in
  let directive = function
    | PStr[
        {pstr_desc =
           Pstr_eval(
             {pexp_desc =
                Pexp_tuple tup
             },
             _
           )
        }
      ] ->
      List.map (fun x ->
        match x with
        | {pexp_desc = Pexp_constant(Const_string(u, None))} -> u
        | _ -> failwithf "Invalid directive"
      )
      tup
    | _ ->
        failwith "Invalid directive"
  in
  let with_ext name f =
    (* See if that extension is available *)
    try
      f (SM.find name !ext)
    with
    | Not_found -> failwithf "Extension %s not found" name
  in
  let apply mapper attr name field =
    debugf "Applying %s" name;
    with_ext name @@ fun x ->
    if x.ext_enabled then
      (field (get_mapper x)) mapper attr
    else
      failwithf "Extension %s not enabled" name
  in
  { default_mapper with
    attribute =
      (
        fun mapper attr ->
          match attr with
          | { txt = t_txt }, p when t_txt = !pfx ->
            (* Syntax node seen.  This is for us *)
              (
                match directive p with
                | ["rename";pfx'] -> pfx := pfx'
                | ["alias";name;name'] ->
                    with_ext name' (fun x -> ext := SM.add name x !ext)
                | ["hide";name] ->
                    with_ext name (fun x -> ext := SM.remove name !ext)
                | ["control";"off"] -> enabled := false;
                | ["control";"on"] -> enabled := true;
                | ["enable";name] ->
                    with_ext name (fun x -> x.ext_enabled <- true)
                | ["disable";name] ->
                    with_ext name (fun x -> x.ext_enabled <- false)
                | d ->
                    failwithf "Unknown directive %s"
                      (String.concat " " d)
              );
              default_mapper.attribute mapper attr
          | { txt = name }, p -> apply mapper attr name (fun x -> x.attribute)
      );
    expr = fun mapper expr ->
      match expr with
      | { pexp_desc =
          Pexp_extension(
            { txt = name },
            p
          ) } ->
          apply mapper expr name (fun x -> x.expr)
      | _ -> default_mapper.expr mapper expr;
  }

open Ppxmgr

module Opt =
struct
  let path = ref ""
  let name = ref "syntax"
  let args : string Queue.t option ref = ref None
  let extensions : (string * string Queue.t) list ref = ref []
end

module Spec =
struct
  open Arg
  open Opt

  let spec =
    align [
      "-path",
      Set_string path,
      "dir Set search path for extensions";

      "-name",
      Set_string name,
      "id Set ID (default is \"syntax\")";

      "-arg",
      String(fun a ->
        match !args with
        | None -> failwithf "Invalid -arg usage; rejecting %S" a
        | Some args -> Queue.push a args),
      "x Add argument to last extension"
    ]
end

let list_of_queue = Queue.fold (fun q x -> x :: q) []

let current_args = ref []

let register name ext =
  debugf "Registering %s" name;
  let x =
    {
      ext_func = ext;
      ext_args = !current_args;
      ext_mapper = None;
      ext_enabled = false;
    }
  in
  extensions := SM.add name x !extensions

let make_mapper argl =
  let argv = Array.of_list ("" :: argl) in
  Arg.parse_argv argv Spec.spec
    (fun ext ->
      Opt.(
        let q = Queue.create () in
        args := Some q;
        extensions := (ext, q) :: !extensions)
     )
    "Invalid ocamlppxmgr usage";

  Ast_mapper.register_function := register;

  List.iter (fun (name, args) ->
    debugf "Loading %s" name;
    current_args := list_of_queue args;
    let fn = Dynlink.adapt_filename (Filename.concat !Opt.path name^".cmo") in
    Dynlink.loadfile fn
  ) !Opt.extensions;

  mapper extensions "syntax"

let () =
  try
    run_main make_mapper
  with
  | Arg.Bad msg ->
      Printf.eprintf "%s: %s\n" Sys.argv.(0) msg;
      exit 1
