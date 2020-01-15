#!/usr/bin/env bash

calculate_dyno_size_based_opts() {
  case $(ulimit -u) in
  512)   # 2X, private-s: memory.limit_in_bytes=1073741824
    echo "-Xmx671m -XX:CICompilerCount=2"
    ;;
  16384) # perf-m, private-m: memory.limit_in_bytes=2684354560
    echo "-Xmx2g"
    ;;
  32768) # perf-l, private-l: memory.limit_in_bytes=15032385536
    echo "-Xmx12g"
    ;;
  *) # Free, Hobby, 1X: memory.limit_in_bytes=536870912
    echo "-Xmx300m -Xss512k -XX:CICompilerCount=2"
    ;;
  esac
}

calculate_java_version_based_opts() {
  if grep -q '^JAVA_VERSION="1[0-9]' "${JAVA_HOME}/release"; then
    echo "-XX:+UseContainerSupport"
  else
    echo ""
  fi
}

# This differs from heroku/jvm, we need a way for the user to disable our defaults
JAVA_TOOL_OPTIONS="$(echo "$(calculate_dyno_size_based_opts) $(calculate_java_version_based_opts)" | tr -s '[:space:]')"
export JAVA_TOOL_OPTIONS
