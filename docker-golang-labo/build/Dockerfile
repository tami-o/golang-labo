# go version
FROM golang:1.19.1-alpine

RUN apk update && apk add git

RUN ls /go/src

RUN mkdir /go/src/golang-labo

WORKDIR /go/src/golang-labo

ADD . /go/src/golang-labo

RUN go mod init golang-lab && go mod tidy

RUN go get -u golang.org/x/tools/cmd/goimports