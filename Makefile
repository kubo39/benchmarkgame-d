SOURCES = $(wildcard source/*.d)
DC ?= dmd
DC_CFLAGS ?= -mcpu=native -O -inline

.PHONY: all distclean clean
.SECONDARY:

all: $(patsubst source/%.d,diff/%.diff, $(SOURCES))

clean:
	rm -fr diff

distclean: clean
	rm -fr bin out

bin/binary_trees:
bin/thread_ring:

bin/%: source/%.d
	mkdir -p bin
	$(DC) $(DC_CFLAGS) $< -of./$@

out/%.txt: bin/% data/%.txt
	mkdir -p out
	$< < data/$*.txt > $@

diff/%.diff: out/%.txt ref/%.txt
	mkdir -p diff
	diff -u ref/$*.txt $< > $@
