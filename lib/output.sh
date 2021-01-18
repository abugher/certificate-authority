#!/bin/bash


prefix="${0}:  "


fail() {
  printf "%s\n" "${prefix}Error:  ${2}"
  exit $1
}


inform() {
  printf "%s\n" "${prefix}Output:  ${1}"
}


prompt() {
  read -p "${prefix}Prompt:  ${1}  " response
  printf "%s\n" "${response}"
}


debug() {
  printf "%s\n" "${prefix}Debug:  ${1}"
}
