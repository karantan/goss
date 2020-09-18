VERSION := 0.3.13
PKG := goss
CLIPKG := $(PKG)/cmd/goss
GOVER := $(shell go version | cut -d ' ' -f 3)
COMMIT := $(shell git rev-parse HEAD)
BUILD_TIME := $(shell date -u +%FT%T)
BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
CURRENT_TARGET = $(PKG)-$(shell uname -s)-$(shell uname -m)
TARGETS := Linux-amd64-x86_64
os = $(word 1, $(subst -, ,$@))
arch = $(word 3, $(subst -, ,$@))
goarch = $(word 2, $(subst -, ,$@))
goos = $(shell echo $(os) | tr A-Z a-z)
output = $(PKG)-$(os)-$(arch)
goflags = -trimpath
.PHONY: $(TARGETS)
$(TARGETS):
	env GOOS=$(goos) GOARCH=$(goarch) go build $(goflags) -o $(output) $(CLIPKG)
.PHONY: install
install:
	go install $(goflags) $(PKG)
#
# Build all defined targets
#
.PHONY: build
build: $(TARGETS)
