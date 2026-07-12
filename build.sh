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

${GREEN}-k          ${RESET}Skip compilation (bun build and tiefdownconverter).
${GREEN}-q          ${RESET}Make script quiet.
${GREEN}-v          ${RESET}Make script verbose.
${GREEN}-h          ${RESET}Show this help.
EOF
}

SOURCE_DIR="${SOURCE_DIR:-web/}"
STATIC_DIR="${STATIC_DIR:-static_resources/}"
DOCS_STATIC_DIR="${DOCS_STATIC_DIR:-Documentation/resources/}"
DOCS_TARGET_DIR="${DOCS_TARGET_DIR:-$SOURCE_DIR/docs/web/}"
DOCS_STATIC_TARGET_DIR="${DOCS_STATIC_TARGET_DIR:-$DOCS_TARGET_DIR/resources/}"
unset -v SKIP_COMPILE
unset -v QUIET
unset -v VERBOSE

while getopts "s:S:kqvh" opt; do
  case $opt in
    k) SKIP_COMPILE=YES ;;
    q) QUIET=YES ;;
    v) VERBOSE=YES ;;
    h) info; exit 0 ;;
    \?) echo "Use -h for help"; exit 1 ;;
  esac
done

# Clean build directory
rm -rf "$SOURCE_DIR"

if [ -z "$SKIP_COMPILE" ]; then
  normal_echo "${CYAN}Building Bootstrap CSS/JS...${RESET}"
  bun run build
fi

normal_echo "${CYAN}Copying static resources from '$STATIC_DIR' to '$SOURCE_DIR'...${RESET}"
cp -a "${STATIC_DIR%/}/." "$SOURCE_DIR"

mkdir -p "$DOCS_STATIC_TARGET_DIR"
normal_echo "${CYAN}Copying documentation static resources from '$DOCS_STATIC_DIR' to '$DOCS_STATIC_TARGET_DIR'...${RESET}"
rsync -a --exclude='*.xcf' "${DOCS_STATIC_DIR%/}/" "$DOCS_STATIC_TARGET_DIR"

if [ -z "$SKIP_COMPILE" ]; then
  normal_echo "${CYAN}Converting with tiefdownconverter...${RESET}"
  tiefdownconverter convert
fi

normal_echo "${GREEN}Build complete.${RESET}"
