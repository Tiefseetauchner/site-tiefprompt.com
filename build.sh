#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=functions.sh
source "$SCRIPT_DIR/functions.sh"

info() {
  echo -e "${GREEN}Build the TiefPrompt site.${RESET}"
  usage
}

usage() {
  cat <<EOF
${YELLOW}usage: build.sh [options]${RESET}

${GREEN}-s dir      ${RESET}Source directory to build into.
            Default: web/
            (i) Can be set via environment variable 'SOURCE_DIR'
${GREEN}-S dir      ${RESET}Static resources directory copied into the source dir.
            Default: static_resources/
            (i) Can be set via environment variable 'STATIC_DIR'
${GREEN}-k          ${RESET}Skip compilation (bun build and tiefdownconverter).
${GREEN}-q          ${RESET}Make script quiet.
${GREEN}-v          ${RESET}Make script verbose.
${GREEN}-h          ${RESET}Show this help.
EOF
}

SOURCE_DIR="${SOURCE_DIR:-web/}"
STATIC_DIR="${STATIC_DIR:-static_resources/}"
unset -v SKIP_COMPILE
unset -v QUIET
unset -v VERBOSE

while getopts "s:S:kqvh" opt; do
  case $opt in
    s) SOURCE_DIR=$OPTARG ;;
    S) STATIC_DIR=$OPTARG ;;
    k) SKIP_COMPILE=YES ;;
    q) QUIET=YES ;;
    v) VERBOSE=YES ;;
    h) info; exit 0 ;;
    \?) echo "Use -h for help"; exit 1 ;;
  esac
done

if [ ! -d "$SOURCE_DIR" ]; then
  error_echo "Source directory '$SOURCE_DIR' does not exist." 1
fi

if [ -z "$SKIP_COMPILE" ]; then
  normal_echo "${CYAN}Building Bootstrap CSS/JS...${RESET}"
  bun run build
fi

if [ -d "$STATIC_DIR" ]; then
  normal_echo "${CYAN}Copying static resources from '$STATIC_DIR' to '$SOURCE_DIR'...${RESET}"
  cp -a "${STATIC_DIR%/}/." "$SOURCE_DIR"
fi

if [ -z "$SKIP_COMPILE" ]; then
  normal_echo "${CYAN}Converting with tiefdownconverter...${RESET}"
  tiefdownconverter convert
fi

normal_echo "${GREEN}Build complete.${RESET}"
