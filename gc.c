#include <stdio.h>
#include <stdlib.h>

// #define TABLE_N 1000000
#define TABLE_N 100
#define NOT_POINTER(x) ((x) & 1)
#define TARGET_IS_NOT_IN_HEAP(x) (((int*)(x) < (int*)min_caml_hbase) || ((int*)min_caml_hend <= (int*)(x)))
#define SIZE_IN_HEADER(x) ((x) >> 10)
#define IS_ZEROTAG(x) (((x) & 0xff) == 0)
#define IS_CLOSURETAG(x) (((x) & 0xff) == 247)
#define IS_DOUBLETAG(x) (((x) & 0xff) == 253)
#define IS_DOUBLE_ARRAY_TAG(x) (((x) & 0xff) == 254)

extern char *min_caml_hp, *min_caml_hbase, *min_caml_hend, *min_caml_next_hbase, *min_caml_next_hend, *min_caml_sbase, *min_caml_stop;

/* "stderr" is a macro and cannot be referred to in libmincaml.S, so
   this "min_caml_stderr" is used (in place of "__iob+32") for better
   portability (under SPARC emulators, for example).  Thanks to Steven
   Shaw for reporting the problem and proposing this solution. */
extern FILE *min_caml_stderr;

int table_search(int *old_p, int *table[TABLE_N][2], int **new_pp) {
  for (int i = 0; table[i][0] != NULL; ++i) {
    if (table[i][0] == old_p) {
      *new_pp = table[i][1];
      return 1;
    }
  }
  return 0;
}

void table_insert(int *old_p, int *new_p, int *table[TABLE_N][2]) {
  int i;
  for (i = 0; table[i][0] != NULL; ++i) { ; }
  table[i][0] = old_p;
  table[i][1] = new_p;
}

void copy(int **hpp, int **old_pp, int *table[TABLE_N][2]) {
  int header = *(*old_pp - 1);
  int size = SIZE_IN_HEADER(header);

  int *new_p = *hpp + 1;
  *hpp += size + 1;

  int *old_p = *old_pp;
  *old_pp = new_p;
  table_insert(old_p, new_p, table);

  *(new_p - 1) = header;
  if (IS_ZEROTAG(header) || IS_CLOSURETAG(header)) {
    for (int i = 0; i < size; ++i) {
      *(new_p + i) = *(old_p + i);
      if (NOT_POINTER(*(new_p + i)) || TARGET_IS_NOT_IN_HEAP(*(new_p + i))) {
        continue;
      }
      int *new;
      if (table_search((int*)*(new_p + i), table, &new)) {
        *(new_p + i) = (int)new;
      } else {
        copy(hpp, (int**)(new_p + i), table);
      }
    }
  } else if (IS_DOUBLETAG(header)) {
    *(double*)new_p = *(double*)old_p;
  } else if (IS_DOUBLE_ARRAY_TAG(header)) {
    for (int i = 0; i < (size / 2); ++i) {
      *((double*)new_p + i) = *((double*)old_p + i);
    }
  }
}

void gc() {
  int *hp = (int*)min_caml_next_hbase;
  int *(*table)[2];
  table = malloc(sizeof(int*) * TABLE_N * 2);
  for (int i = 0; i < TABLE_N; ++i) { table[i][0] = NULL; }
  for (int *sp = (int*)min_caml_sbase; sp < (int*)min_caml_stop; ++sp) {
    if (NOT_POINTER(*sp)) { continue; }
    if (TARGET_IS_NOT_IN_HEAP(*sp)) { continue; }
    int *new_p;
    if (table_search((int*)*sp, table, &new_p)) {
      *sp = (int)new_p;
    } else {
      copy(&hp, (int**)sp, table);
    }
  }

  min_caml_hp = (char*)hp;
  char *tmp = min_caml_next_hbase;
  min_caml_next_hbase = min_caml_hbase;
  min_caml_hbase = tmp;
  tmp = min_caml_next_hend;
  min_caml_next_hend = min_caml_hend;
  min_caml_hend = tmp;
}

void gc_fail() {
  fprintf(stderr, "gc_fail\n");
  exit(0);
}
