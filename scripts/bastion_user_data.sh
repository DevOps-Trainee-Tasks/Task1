#!/bin/sh
set -eu

if ! command -v psql >/dev/null 2>&1; then
  dnf install -y postgresql16
fi
