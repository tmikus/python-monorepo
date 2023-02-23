#!/usr/bin/env bash

function build_all_packages() {
  echo "Building all packages..."
  # for each package from find_all_packages run build_package
  for package in $(find_all_packages || exit); do
    build_package "$package" || exit
  done
}

function build_docker() {
  echo "Building docker image..."
  docker build -t api:latest . || exit
}

function build_package() {
  path="$1"
  package_name=$(basename "$path")
  echo "Building package \"$package_name\"..."
  (cd "$path" && python -m build --no-isolation) || exit
}

function collect_wheels() {
  echo "Collecting wheels..."
  rm -rf build || exit
  mkdir -p build || exit
  (find . -name "*.whl" -not -path "./build/*" -exec cp {} build \;) || exit
}

function find_all_packages() {
  (find . -name "pyproject.toml" -not -path "./build/*" -exec dirname {} \;) || exit
}

function run_docker() {
  echo "Running docker image..."
  docker run --rm -it api:latest || exit
}

build_all_packages
collect_wheels
build_docker
run_docker
