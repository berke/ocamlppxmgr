(* Example *)

[@@@syntax ("enable","example_extension")]
let a = [%example_extension "USER"]
[@@@syntax ("alias","foo","example_extension")]
let b = [%foo "USER"]
let c = [%example_extension "USER"]
[@@@syntax ("hide","example_extension")]
let d = [%foo "USER"]
