# liteJQ: jq support in SQLite</strong>

<a href="https://github.com/Florents-Tselai/litejq/actions/workflows/test.yml?branch=mainline"><img src="https://github.com/Florents-Tselai/litejq/actions/workflows/test.yml/badge.svg"></a>
<a href="https://opensource.org/licenses/MIT License"><img src="https://img.shields.io/badge/MIT License-blue.svg"></a>
<img alt="GitHub Repo stars" src="https://img.shields.io/github/stars/Florents-Tselai/liteJQ">


**liteJQ** is an SQLite extension, written in C, that brings `jq` support to SQLite.
It uses vanilla `jqlib`.

## Usage

```sqlite
SELECT jq(json, jqprog)
```

### Examples

We'll use the movies dataset as a running example.
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
| jq(d, '.title') |
| --- |
| Combat Shock |
| Night Court |
| Jimmie's Millions |
| Tai-Pan |
| Werewolves Within |
**To find movies released in a specific year, for example, 1945**


```sql
select jq(d, '{title: .title, year: .year}')
from movies
where jq(d, 'select(.year) > 1990');
```
| jq(d, '{title: .title, year: .year}') |
| --- |
| {"title":"Combat Shock","year":1986} |
| {"title":"Night Court","year":1932} |
| {"title":"Jimmie's Millions","year":1925} |
| {"title":"Tai-Pan","year":1986} |
| {"title":"Werewolves Within","year":2021} |
**Extract Movies with Specific Keywords in Extract**


```sql
select jq(d, '.extract')
from movies
where jq(d, '.extract | contains("silent")');
```
| jq(d, '.extract') |
| --- |
| Jimmie's Millions is a 1925 American silent action film directed by James P. Hogan and starring Richard Talmadge, Betty Francisco, and Charles Clary. |
| Women and Gold is a 1925 American silent drama film directed by James P. Hogan and starring Frank Mayo, Sylvia Breamer and William B. Davidson. It was produced by the independent Gotham Pictures. |
| The Rough Neck is a 1919 American silent drama film directed Oscar Apfel and starring Montagu Love, Robert Broderick and Barbara Castleton. |
| Quicksand is a lost 1918 American silent drama film directed by Victor Schertzinger and written by John Lynch and R. Cecil Smith. The film stars Henry A. Barrows, Edward Coxen, Dorothy Dalton, Frankie Lee, and Philo McCullough. The film was released on December 22, 1918, by Paramount Pictures. |
| Sweet and Low is a 1914 American silent short drama film starring William Garwood, Harry von Meter, and Vivian Rich, directed by Sydney Ayres, and released by Mutual Film Corporation on October 28, 1914. The film is based upon the 1850 poem Lullaby/Sweet and Low by Alfred, Lord Tennyson. |

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

On Linux, things can be trickier because
most distros don't have `jq` configured,
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

# Others

There is [another](https://mgdm.net/weblog/using-jq-in-sqlite/) similar extension, but it's written in Go and relies on a non-vanilla implementation of JQ.
