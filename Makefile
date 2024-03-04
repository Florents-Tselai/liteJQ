CC=gcc
UNAME_S=$(shell uname -s)
UNAME_M=$(shell uname -m)
LITEJQ_VERSION:=$(shell git tag --points-at HEAD)

ifeq (Darwin,$(UNAME_S))
CFLAGS:=-Wall -Wsign-compare -fPIC -dynamiclib -DLITEJQ_VERSION=$(LITEJQ_VERSION)
else ifeq (Linux,$(UNAME_S))
CFLAGS=-z now -z relro -Wall -Wsign-compare -Wno-unknown-pragmas -fPIC -shared -DLITEJQ_VERSION=$(LITEJQ_VERSION)
else
CFLAGS=-shared -fPIC
endif

SRC=litejq.c
OUT=litejq
PKG_CONFIG ?= pkg-config

ifeq (no,$(shell $(PKG_CONFIG) jq || echo no))
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

dev: clean all test

.PHONY: dev
.default: all dist

DIST_ZIP=./dist/litejq-$(LITEJQ_VERSION)-$(UNAME_S)-$(UNAME_M).zip

$(DIST_ZIP): $(OUT)
	mkdir -p dist
	zip -p $@ $^

dist: $(DIST_ZIP)

clean:
	-rm -f $(OUT)
	-rm tests/output/*.sql
	-rm -rf dist/
