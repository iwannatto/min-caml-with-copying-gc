let a = Array.make 50 0.0 in
let b = read_float_0 () in
let rec loop i =
  if (i >= 50) then () else
  let c = b +. 1.0 in
  do_nothing c;
  a.(i) <- c;
  loop (i + 1) in
loop 0;
prerr_float (a.(30)); prerr_byte 10
