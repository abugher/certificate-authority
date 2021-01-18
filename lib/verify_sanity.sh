#!/bin/bash


function verify_sanity() {
  if test "${#}" -gt 1; then
    fail $ERR_USAGE "Specify at most one short hostname."
  fi

  for prereq in "${verify_prereqs}"; do
    if ! test -e "${prereq}"; then
      fail $ERR_PREREQ "Required file does not exist:  ${prereq}"
    fi
  done
}
