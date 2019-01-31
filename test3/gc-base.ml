let a = read_int_0 () + 1 in
let b = read_float_0 () +. 10.0 in
let rec f c = a + (int_of_float b) + c in
prerr_int (f 100); prerr_byte 10;
let t = (a, (int_of_float b)) in
do_nothing t;
let int_a = Array.make 13 a in
let float_a = Array.make 50 b in
prerr_int int_a.(0); prerr_byte 10;
prerr_float float_a.(0); prerr_byte 10
