#!/usr/bin/env bash

log_header() {
  local color="\033[1;35m"
  local no_color="\033[0m"
  echo -e "\n${color}[${1:-""}]${no_color}"
}

log_info() {
  echo -e "${1:-""}"
}

log_error() {
  local color="\033[1;91m"
  local no_color="\033[0m"

  echo -e "\n${color}Error: ${1:-"Unknown Error"}${no_color}"
  echo -e "${2}\n"
}

log_notice() {
  local color="\033[1;92m"
  local no_color="\033[0m"

  echo -e "\n${color}Notice: ${1:-"Unknown"}${no_color}"
  echo -e "${2}\n"
}
