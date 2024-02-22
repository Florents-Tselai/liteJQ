CC=gcc
CFLAGS=-shared -fPIC
SRC=litejq.c
OUT=litejq
PKG_CONFIG ?= pkg-config

ifeq (no,$(shell $(PKG_CONFIG) libjq || echo no))
$(warning "libjq not registed with pkg-config, build might fail. If it does, try setting JQ_PREFIX manually and run with `JQ_PREFIX=/path/to/dir make all`")
LIBJQ_LIBS=-I$(JQ_PREFIX)/include -L$(JQ_PREFIX)/lib -ljq
else
LIBJQ_LIBS=$(shell $(PKG_CONFIG) --cflags --libs libjq)
endif

SQLITE3_LIBS=$(shell $(PKG_CONFIG) --cflags --libs sqlite3)

all: $(OUT)

$(OUT): $(SRC)
	$(CC) $(CFLAGS) -o $(OUT) $(SRC) $(SQLITE3_LIBS) $(LIBJQ_LIBS)

.PHONY: run-test-%
run-test-%:
	echo "running test: tests/$*.sql"
	sqlite3 :memory: <tests/$*.sql >tests/output/$*.sql
	diff tests/output/$*.sql tests/expected/$*.sql

test: run-test-basic run-test-complex

clean:
	-rm -f $(OUT)
	-rm tests/output/*.sql

dev: clean all test

.PHONY: dev
.default: all
