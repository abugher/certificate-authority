#!/bin/bash

remove_stale() {
  for file in "${@}"; do
    if test -e $file; then
      rm $file \
      || fail $ERR_KEY "Failed to remove stale file:  ${file}"
      inform "Removed stale file:  ${file}"
    fi
  done
}
