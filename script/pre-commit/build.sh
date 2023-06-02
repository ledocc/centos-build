#!/usr/bin/env bash

VERSION=3.3.2
ARCHIVE=pre-commit-${VERSION}.pyz


curl -L -O https://github.com/pre-commit/pre-commit/releases/download/v${VERSION}/pre-commit-${VERSION}.pyz

cp ${ARCHIVE} /tmp/install

