let rec inprod v1 v2 v3 i =
  if i < 0 then 0 else
  v1.(i) + v1.(i) - v2.(i) + inprod v1 v2 v3 (i - 1) in
let v1 = Array.make 8 123 in
let v2 = Array.make 8 456 in
let v3 = Array.make 10 1.0 in
print_int (inprod v1 v2 v3 4)
