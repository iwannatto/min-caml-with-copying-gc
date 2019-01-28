let a = (read_float ()) in
let rec f b = a +. b in
prerr_float (f (read_float ()))
