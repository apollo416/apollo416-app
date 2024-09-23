#!/bin/bash

GOFLAGS="-buildvcs=false -trimpath '-ldflags=-s -w -buildid='" \
CGO_ENABLED=0 \
GOOS=linux \
GOARCH=arm64 \
go build \
-tags lambda.norpc \
-o ./bin/engine/bootstrap \
./src/apollo416/cmd/engine/main.go

