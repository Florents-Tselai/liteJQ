# liteJQ: jq support in SQLite</strong>

<a href="https://github.com/Florents-Tselai/litejq/actions/workflows/test.yml?branch=mainline"><img src="https://github.com/Florents-Tselai/litejq/actions/workflows/test.yml/badge.svg"></a>
<a href="https://opensource.org/licenses/MIT License"><img src="https://img.shields.io/badge/MIT License-blue.svg"></a>
<img alt="GitHub Repo stars" src="https://img.shields.io/github/stars/Florents-Tselai/liteJQ">


**liteJQ** is an SQLite extension, written in C, that brings `jq` support to SQLite.
It uses vanilla `libjq`.

## Motivation

SQLite has been supporting JSON operators for years. Complex queries, however, involving JSON can be more cumbersome to write and understand, especially when compared to more complex systems like PostgreSQL. **liteJQ** attempts to alleviate that by bringing the expressive power of jq into SQLite.

## Installation

```sh
make
```

This produces a `litejq` binary object, which should be loaded in SQLite at runtime.

Verify the installation.

```sh
sqlite3 :memory: <<EOF
.load ./litejq
select jq('{"key": "litejq is loaded"}', '.key')
EOF
```

## Usage

```sqlite
SELECT jq(json, jqprog)
```

### Examples

We'll use the movie dataset as a running example.
```bash
sqlite3 movies.db < ./data/movies.sql
```
We have a very simple schema:
```sqlite
CREATE TABLE [movies] (
   "d" TEXT -- json
);
```
Column `d` holds json values in plain text like this.
```json
{
    "title": "The Corn Is Green",
    "year": 1945,
    "cast": [
      "Bette Davis",
      "Joan Lorring",
      "John Dall"
    ],
    "genres": [
      "Drama"
    ],
    "href": "The_Corn_Is_Green_(1945_film)",
    "extract": "The Corn Is Green is a 1945 American drama film starring Bette Davis as a schoolteacher determined to bring education to a Welsh coal mining town despite great opposition. It was adapted from the 1938 play of the same name by Emlyn Williams, which originally starred Ethel Barrymore.",
    "thumbnail": "https://upload.wikimedia.org/wikipedia/en/thumb/b/bf/The-corn-is-green-poster.jpg/320px-The-corn-is-green-poster.jpg",
    "thumbnail_width": 320,
    "thumbnail_height": 248
  }
```
In any session, you should load the extension first after building it, like this:
```sqlite
.load ./litejq
```
Then you can start doing `jq` magic.
Let's see some example queries.

**List all movie titles**


```sql
select jq(d, '.title')
from movies;
```

**To find movies released after a specific year, for example, 1980**

```sql
select jq(d, '{title: .title, year: .year}')
from movies
where jq(d, '.year > 1980');
```
The above query is equivalent to this one
```sql
select jq(d, '{title: .title, year: .year}')
from movies
where jq(d, '.year') > 1980;
```

**Extract Movies with Specific Keywords in Extract**

```sql
select jq(d, '.extract')
from movies
where jq(d, '.extract | contains("silent")');
```

**Filter movies by a specific genre (e.g., Drama)**

```sql
select jq(d, '{title: .title, year: .year, genres: .genres}')
from movies
where jq(d, '.genres[] == "Drama"');
```

**Filter movies where "Joan Lorring" and "John Dall" played together**

```sql
select jq(d, '{title: .title, year: .year, cast: .cast}')
from movies
where jq(d, '.cast | contains(["Joan Lorring", "John Dall"])');
```

**Group by movies by release year**

```sql
select jq(d, '.year'), count(*)
from movies
group by jq(d, '.year')
```

## Notes On Installation

For this to work, you'll need development files for both SQLite and jq.

### MacOS

```sh
brew install jq sqlite3
make all
```

I've found that `brew` installs header files auomatically for you,
so there's nothing else you have to do

Verify installation

```sh
sqlite3 :memory: <<EOF
.load ./litejq
select jq('{"key": "value"}', '.key')
EOF
```

### Linux

```sh
sudo apt install sqlite3 libsqlite3-dev jq libjq-dev
```

On Linux, sometimes things can be trickier because
many distros don't have `jq` configured with `pkg-config`
so your best guess would be installing `jq` from source first.

If you already have `jq` installed to a known prefix,
try using it explicitly:

```sh
JQ_PREFIX=/usr/local make
```

If this doesn't work,
you can (and probably should) build it from source.

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

```sh
sqlite3 :memory: <<EOF
.load ./litejq
select jq('{"key": "litejq is loaded"}', '.key')
EOF
```

# Others

There is [another](https://mgdm.net/weblog/using-jq-in-sqlite/) similar extension, but it's written in Go and relies on a non-vanilla implementation of JQ.
