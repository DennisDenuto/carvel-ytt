#!/bin/bash

set -e -x -u

LATEST_GIT_TAG=$(git describe --tags | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+')
VERSION="${1:-$LATEST_GIT_TAG}"

go fmt ./cmd/... ./pkg/... ./test/...
go mod vendor
go mod tidy

# makes builds reproducible
export CGO_ENABLED=0
LDFLAGS="-X github.com/k14s/ytt/pkg/version.Version=$VERSION -buildid="

GOOS=darwin GOARCH=amd64 go build -ldflags="$LDFLAGS" -trimpath -o ytt-darwin-amd64 ./cmd/ytt
GOOS=darwin GOARCH=arm64 go build -ldflags="$LDFLAGS" -trimpath -o ytt-darwin-arm64 ./cmd/ytt
GOOS=linux GOARCH=amd64 go build -ldflags="$LDFLAGS" -trimpath -o ytt-linux-amd64 ./cmd/ytt
GOOS=linux GOARCH=arm64 go build -ldflags="$LDFLAGS" -trimpath -o ytt-linux-arm64 ./cmd/ytt
GOOS=windows GOARCH=amd64 go build -ldflags="$LDFLAGS" -trimpath -o ytt-windows-amd64.exe ./cmd/ytt

shasum -a 256 ./ytt-darwin-amd64 ./ytt-darwin-arm64 ./ytt-linux-amd64 ./ytt-linux-arm64 ./ytt-windows-amd64.exe
