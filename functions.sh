#!/bin/bash
# Shared helpers for build.sh and deploy.sh.
# Source this file; it defines colors and logging helpers.
# Honors the QUIET and VERBOSE environment/shell variables.

GREEN=$'\033[0;32m'
RED=$'\033[0;31m'
YELLOW=$'\033[0;33m'
CYAN=$'\033[0;36m'
RESET=$'\033[0;0m'

error_echo() {
  echo -e "${RED}ERROR: $1$RESET"
  exit "$2"
}

normal_echo() {
  if [ -z "$QUIET" ]; then
    echo -e "$1"
  fi
}

verbose_echo() {
  if [ "$VERBOSE" ]; then
    echo -e "$1"
  fi
}

verbose_echo_stdin() {
  program_name="$1"
  while IFS= read -r line; do
    verbose_echo "$GREEN$program_name:$RESET $line"
  done
}

normal_echo_stderr() {
  program_name="$1"
  while IFS= read -r line; do
    normal_echo "${RED}$program_name:$RESET $line"
  done >&2
}
