let x = read_float () in
let y = read_int () in
let rec f z = x +. (float_of_int y) +. z in
prerr_float (f 3.0); prerr_byte 10
