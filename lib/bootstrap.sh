#!/usr/bin/env bash
set -eo pipefail

# shellcheck disable=SC2091
# shellcheck source=./logging.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/logging.sh"

bootstrap() {
  log_header "Bootstrapping buildpack"

  local buildpack_directory=$1
  local layers_directory=$2

  bootstrap_layer_directory="${layers_directory}/bootstrap"
  mkdir -p "${bootstrap_layer_directory}"

  bootstrap_layer_toml="${bootstrap_layer_directory}.toml"

  cat << TOML > "${bootstrap_layer_toml}"
launch = false
cache = false
build = false
TOML

  log_info "Downloading go..."
  local go_directory
  go_directory="$(mktemp -d)"

  local local_go_tarball
  local_go_tarball="$(mktemp /tmp/go.tar.gz.XXXXXX)"

  curl --retry 3 -sf -o "$local_go_tarball" -L https://dl.google.com/go/go1.12.9.linux-amd64.tar.gz

  log_info "Installing go..."
  tar -C "$go_directory" -xzf "$local_go_tarball"

  # go build seems only to work with a relative path and errors out when we use an absolute path.
  # We change directories and change back later before returning from this function.
  previous_directory=$(pwd)
  cd "${buildpack_directory}"

  for cmd in "jdk-version-tool"; do
    log_info "Building ${cmd}..."
    "${go_directory}/go/bin/go" get -d "./cmd/${cmd}/..."
    "${go_directory}/go/bin/go" build -o "${bootstrap_layer_directory}/bin/$cmd" "./cmd/${cmd}/..."
    chmod +x "${bootstrap_layer_directory}/bin/$cmd"
  done

  export PATH="$PATH:${bootstrap_layer_directory}/bin"

  cd "${previous_directory}"
  log_info "Bootstrap successful!"
}
