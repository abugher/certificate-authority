#!/bin/bash

for lib in output remove_stale errors vars dependencies; do
  lib_path="${certificate_authority}/lib/${lib}.sh"
  if ! test -e "${lib_path}"; then
    echo "Missing library:  ${lib_path}"
    exit 1
  fi
  . "${lib_path}"
done
