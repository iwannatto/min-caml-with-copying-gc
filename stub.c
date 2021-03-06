#include <stdio.h>
#include <stdlib.h>

extern char *min_caml_hbase, *min_caml_hend, *min_caml_next_hbase, *min_caml_next_hend, *min_caml_sbase;
extern void min_caml_start(char *, char *);

/* "stderr" is a macro and cannot be referred to in libmincaml.S, so
   this "min_caml_stderr" is used (in place of "__iob+32") for better
   portability (under SPARC emulators, for example).  Thanks to Steven
   Shaw for reporting the problem and proposing this solution. */
FILE *min_caml_stderr;

int main() {
  char *hp, *sp;
  // int hsize = 4000000;
  int hsize = 4 * 0x100;

  min_caml_stderr = stderr;
  sp = alloca(1000000); hp = malloc(hsize);
  if (hp == NULL || sp == NULL) {
    fprintf(stderr, "malloc or alloca failed\n");
    return 1;
  }
  fprintf(stderr, "sp = %p, hp = %p\n", sp, hp);

  min_caml_hbase = hp;
  min_caml_hend = hp + (hsize / 2);
  min_caml_next_hbase = min_caml_hend;
  min_caml_next_hend = hp + hsize;
  min_caml_sbase = sp;

  min_caml_start(sp, hp);

  return 0;
}
