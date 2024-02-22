# liteJQ: jq support in SQLite</strong>

<a href="https://github.com/Florents-Tselai/litejq/actions/workflows/test.yml?branch=mainline"><img src="https://github.com/Florents-Tselai/litejq/actions/workflows/test.yml/badge.svg"></a>
<a href="https://opensource.org/licenses/MIT license"><img src="https://img.shields.io/badge/MIT license-blue.svg"></a>
<img alt="GitHub Repo stars" src="https://img.shields.io/github/stars/Florents-Tselai/liteJQ">


**liteJQ** is an SQLite extension, written in C, that brings `jq` support to SQLite.
It uses vanilla `jqlib`.

## Usage

```sqlite
SELECT jq(json, jqprog)
```

### Examples 

```sql

sqlite3 :memory: <<EOF
.load ./litejq
.echo on

select jq('{"a":2,"c":[4,5,{"f":7}]}', '.'); --> {"a":2,"c":[4,5,{"f":7}]}
select jq('{"a":2,"c":[4,5,{"f":7}]}', '.c') --> '[4,5,{"f":7}]'
select jq('{"a":2,"c":[4,5,{"f":7}]}', '.c[2]') --> '{"f":7}
select jq('{"a":2,"c":[4,5,{"f":7}]}', '.c[2].f') --> 7
select jq('{"a":2,"c":[4,5],"f":7}','.c[-1]') --> 5
select jq('{"a":2,"c":[4,5,{"f":7}]}', '.x') --> NULL
select jq('{"a":"xyz"}', '.a | length + 2') --> 5
select jq('{"a":null}', '.a') --> NULL
select jq('{"a":true}', '.a') --> 1
EOF
```

## Installation

### MacOS

```sh
brew install jq sqlite3
make all
```

Verify installation

```sh
sqlite3 :memory: <<EOF
.load ./litejq
select jq('{"key": "value"}', '.key')
EOF
```

### Linux

On Linux things can be trickier because
most distros don't have `jq` configured,
so your best guess would be installint `jq` from source first.

If you already have `jq` installed to a known prefix,
try using it explicitely:

```sh
JQ_PREFIX=/usr/local make
```

If this doesn't work,
you can (and probably should) build it from source

#### Build `jq` from source

```sh
cd /tmp &&
  wget "https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-1.7.1.tar.gz" &&
  tar xzf jq-1.7.1.tar.gz &&
  cd jq-1.7.1 &&
  ./configure --with-oniguruma=builtin --prefix=/usr/local &&
  sudo make install
```

Then try again

```sh
make
```

# Others

There is [another](https://mgdm.net/weblog/using-jq-in-sqlite/) similar extension but
But it's written in Go and relies on a non-vanilla implementation of JQ.
