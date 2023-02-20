#!/usr/bin/env bash

function build_package() {
  path="$1"
  package_name=$(basename "$path")
  echo "Building package \"$package_name\"..."
  (cd "$path" && python -m build --no-isolation) || exit
}

build_package "api"
build_package "utils"
