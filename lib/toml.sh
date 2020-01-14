#!/usr/bin/env bash

toml_get_key() {
  local file="$1"
  local key="$2"

  if [[ -f $file ]]; then
    yj -t < "${file}" | jq -r "${key}"
  else
    echo ""
  fi
}
