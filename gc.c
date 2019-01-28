#include <stdio.h>
#include <stdlib.h>

/* "stderr" is a macro and cannot be referred to in libmincaml.S, so
   this "min_caml_stderr" is used (in place of "__iob+32") for better
   portability (under SPARC emulators, for example).  Thanks to Steven
   Shaw for reporting the problem and proposing this solution. */
FILE *min_caml_stderr;

void gc() {
  min_caml_stderr = stderr;
  fprintf(stderr, "gc\n");
  exit(0);
}
