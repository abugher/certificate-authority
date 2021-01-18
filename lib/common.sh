#!/bin/bash

libs+=(
  'output'
  'remove_stale'
  'errors'
  'vars'
  'dependencies'
)

for lib in "${libs[@]}"; do
  lib_path="${certificate_authority}/lib/${lib}.sh"
  if ! . "${lib_path}"; then
    echo "Failed to load library:  ${lib_path}" >&2
    exit 1
  fi
done
