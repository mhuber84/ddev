# Makefile for a standard golang repo with associated container

##### These variables need to be adjusted in most repositories #####

# This repo's root import path (under GOPATH).
PKG := github.com/drud/ddev

# Docker repo for a push
#DOCKER_REPO ?= drud/drupal-deploy

# Upstream repo used in the Dockerfile
#UPSTREAM_REPO ?= drud/site-deploy:latest

# Top-level directories to build
SRC_DIRS := cmd pkg

# Optional to docker build
#DOCKER_ARGS =

# VERSION can be set by
  # Default: git tag
  # make command line: make VERSION=0.9.0
# It can also be explicitly set in the Makefile as commented out below.

# This version-strategy uses git tags to set the version string
# VERSION can be overridden on make commandline: make VERSION=0.9.1 push
VERSION := $(shell git describe --tags --always --dirty)
#
# This version-strategy uses a manual value to set the version string
#VERSION := 1.2.3

# Each section of the Makefile is included from standard components below.
# If you need to override one, import its contents below and comment out the
# include. That way the base components can easily be updated as our general needs
# change.
include build-tools/makefile_components/base_build_go.mak
#include build-tools/makefile_components/base_build_python-docker.mak
#include build-tools/makefile_components/base_container.mak
#include build-tools/makefile_components/base_push.mak
include build-tools/makefile_components/base_test_go.mak
#include build-tools/makefile_components/base_test_python.mak

TESTOS = $(shell uname -s | tr '[:upper:]' '[:lower:]')
DDEV_BINARY_FULLPATH=$(shell pwd)/bin/$(TESTOS)/ddev

# Override test section with tests specific to ddev
test: build setup
	@mkdir -p bin/linux bin/darwin
	@mkdir -p .go/src/$(PKG) .go/pkg .go/bin .go/std/linux
	PATH=$$PWD/bin/$(TESTOS):$$PATH DDEV_BINARY_FULLPATH=$(DDEV_BINARY_FULLPATH) go test -timeout 20m -v ./cmd/ddev/cmd
	PATH=$$PWD/bin/$(TESTOS):$$PATH DDEV_BINARY_FULLPATH=$(DDEV_BINARY_FULLPATH) DRUD_DEBUG=true go test -timeout 20m -v ./pkg/...

setup:
	@mkdir -p bin/darwin bin/linux
	@if [ ! -L $$PWD/bin/darwin/ddev ] ; then ln -s $$PWD/bin/darwin/darwin_amd64/ddev $$PWD/bin/darwin/ddev; fi
