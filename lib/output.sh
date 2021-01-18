#!/bin/bash


prefix="${0}:  "


fail() {
  printf "%s\n" "${prefix}Error:  ${2}" >&2
  exit $1
}


inform() {
  printf "%s\n" "${prefix}${1}"
}


debug() {
  if test 'set' = "${DEBUG:+set}"; then
    inform "DEBUG:  ${1}"
  fi
}
