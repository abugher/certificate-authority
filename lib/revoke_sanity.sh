#!/bin/bash

function revoke_sanity() {
  if test "${#}" -ne 1; then
    fail $ERR_USAGE "Specify one short hostname."
  fi

  for prereq in ca_intermediate_conf ca_intermediate_key host_cert; do
    if ! test -e "${!prereq}"; then
      fail $ERR_PREREQ "Required file does not exist:  ${!prereq}"
    fi
  done
}
