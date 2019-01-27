# Sumii's Makefile for Min-Caml (for GNU Make)
#
# ack.mlなどのテストプログラムをtest/に用意してmake do_testを実行すると、
# min-camlとocamlでコンパイル・実行した結果を自動で比較します。

RESULT = min-caml
NCSUFFIX = .opt
CC = gcc
CFLAGS = -g -O2 -Wall
OCAMLLDFLAGS=-warn-error -31

default: debug-code top $(RESULT) do_test
$(RESULT): debug-code top
## [自分（住井）用の注]
## ・OCamlMakefileや古いGNU Makeのバグ(?)で上のような定義が必要(??)
## ・OCamlMakefileではdebug-codeとnative-codeのそれぞれで
##   .mliがコンパイルされてしまうので、両方ともdefault:の右辺に入れると
##   再make時に（.mliが変更されているので）.mlも再コンパイルされる
clean:: nobackup

# ↓もし実装を改造したら、それに合わせて変える
SOURCES = float.c type.ml id.ml m.ml s.ml \
syntax.ml parser.mly lexer.mll typing.mli typing.ml kNormal.mli kNormal.ml \
alpha.mli alpha.ml beta.mli beta.ml assoc.mli assoc.ml \
inline.mli inline.ml constFold.mli constFold.ml elim.mli elim.ml \
closure.mli closure.ml asm.mli asm.ml virtual.mli virtual.ml \
simm.mli simm.ml regAlloc.mli regAlloc.ml emit.mli emit.ml \
main.mli main.ml

# ↓テストプログラムが増えたら、これも増やす
TESTS = print sum-tail gcd sum fib ack even-odd \
adder funcomp cls-rec cls-bug cls-bug2 cls-reg-bug \
shuffle spill spill2 spill3 join-stack join-stack2 join-stack3 \
join-reg join-reg2 non-tail-if non-tail-if2 \
inprod inprod-rec inprod-loop matmul matmul-flat \
manyargs
TESTS2 = read-int print-byte
TESTS3 = prerr-int prerr-byte prerr-float float-of-int cls-float tuple-float

do_test: $(TESTS:%=test/%.cmp) $(TESTS2:%=test2/%.cmp) $(TESTS3:%=test3/%.cmp)

.PRECIOUS: test/%.s test/% test/%.res test/%.ans test/%.cmp \
	test2/%.s test2/% test2/%.res test2/%.cmp \
	test3/%.s test3/% test3/%.res test3/%.cmp
TRASH = $(TESTS:%=test/%.s) $(TESTS:%=test/%) $(TESTS:%=test/%.res) $(TESTS:%=test/%.ans) $(TESTS:%=test/%.cmp) \
	$(TESTS2:%=test2/%.s) $(TESTS2:%=test2/%) $(TESTS2:%=test2/%.res) $(TESTS2:%=test2/%.cmp) \
	$(TESTS3:%=test3/%.s) $(TESTS3:%=test3/%) $(TESTS3:%=test3/%.res) $(TESTS3:%=test3/%.cmp) \
	minitest.s minitest

.PHONY: minitest
minitest: $(RESULT) minitest.ml libmincaml.S stub.c
	./$(RESULT) minitest
	$(CC) $(CFLAGS) -m32 minitest.s libmincaml.S stub.c -lm -o $@
	./minitest

test/%.s: $(RESULT) test/%.ml
	./$(RESULT) test/$*
test/%: test/%.s libmincaml.S stub.c
	$(CC) $(CFLAGS) -m32 $^ -lm -o $@
test/%.res: test/%
	$< > $@
test/%.ans: test/%.ml
	ocaml $< > $@
test/%.cmp: test/%.res test/%.ans
	diff $^ > $@

test2/%.s: $(RESULT) test2/%.ml
	./$(RESULT) test2/$*
test2/%: test2/%.s libmincaml.S stub.c
	$(CC) $(CFLAGS) -m32 $^ -lm -o $@
test2/%.res: test2/%
	$< < test2/$*.in > $@
test2/%.cmp: test2/%.res test2/%.ans
	diff $^ > $@

test3/%.s: $(RESULT) test3/%.ml
	./$(RESULT) test3/$*
test3/%: test3/%.s libmincaml.S stub.c
	$(CC) $(CFLAGS) -m32 $^ -lm -o $@
test3/%.res: test3/%
	$< < test3/$*.in 2> $@_
	sed -e '1d' $@_ > $@
	rm $@_
test3/%.cmp: test3/%.res test3/%.ans
	diff $^ > $@

min-caml.html: main.mli main.ml id.ml m.ml s.ml \
		syntax.ml type.ml parser.mly lexer.mll typing.mli typing.ml kNormal.mli kNormal.ml \
		alpha.mli alpha.ml beta.mli beta.ml assoc.mli assoc.ml \
		inline.mli inline.ml constFold.mli constFold.ml elim.mli elim.ml \
		closure.mli closure.ml asm.mli asm.ml virtual.mli virtual.ml \
		simm.mli simm.ml regAlloc.mli regAlloc.ml emit.mli emit.ml
	./to_sparc
	caml2html -o min-caml.html $^
	sed 's/.*<\/title>/MinCaml Source Code<\/title>/g' < min-caml.html > min-caml.tmp.html
	mv min-caml.tmp.html min-caml.html
	sed 's/charset=iso-8859-1/charset=euc-jp/g' < min-caml.html > min-caml.tmp.html
	mv min-caml.tmp.html min-caml.html
	ocaml str.cma anchor.ml < min-caml.html > min-caml.tmp.html
	mv min-caml.tmp.html min-caml.html

release: min-caml.html
	rm -fr tmp ; mkdir tmp ; cd tmp ; cvs -d:ext:sumii@min-caml.cvs.sf.net://cvsroot/min-caml export -Dtomorrow min-caml ; tar cvzf ../min-caml.tar.gz min-caml ; cd .. ; rm -fr tmp
	cp Makefile stub.c SPARC/libmincaml.S min-caml.html min-caml.tar.gz ../htdocs/

include OCamlMakefile
