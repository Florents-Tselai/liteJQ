FROM ubuntu:noble
RUN apt-get update
RUN apt-get install -y build-essential pkg-config sqlite3 libsqlite3-dev libjq-dev git

WORKDIR /litejq
COPY . /litejq

RUN make && make test
