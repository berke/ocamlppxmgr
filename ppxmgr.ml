(* Ppxmgr *)

open Printf

let debug_enabled = ref true

let debugf fmt =
  if !debug_enabled then
    (
      fprintf stderr "PPX debug: ";
      kfprintf (fun oc ->
          fprintf oc "\n%!")
        stderr fmt
    )
  else
    ifprintf stderr fmt

let debugf0 fmt = ifprintf stderr fmt

let failwithf fmt =
  let b = Buffer.create 80 in
  Buffer.add_string b "PPX failure: ";
  kbprintf (fun b -> failwith @@ Buffer.contents b) b fmt

