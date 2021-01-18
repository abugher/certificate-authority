#!/bin/bash

function generate_sanity() {
  if test 'ca' = "${host}"; then
    fail $ERR_USAGE "'ca' may not be a primary hostname."
  fi

  for prereq in "${generate_prereqs[@]}"; do
    if ! test -e "${prereq}"; then
      fail $ERR_PREREQ "Required file does not exist:  ${prereq}"
    fi
  done

  debug "Sanity checks passed."
}
