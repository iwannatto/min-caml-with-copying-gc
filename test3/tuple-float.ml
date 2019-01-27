let a = (read_float (), read_int (), read_float ()) in
let (b, c, d) = a in
prerr_float (b +. (float_of_int c) +. d); prerr_byte 10
