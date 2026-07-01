#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=functions.sh
source "$SCRIPT_DIR/functions.sh"

info() {
  echo -e "${GREEN}Deploy TiefPrompt site to a remote server.${RESET}"
  usage
}

usage() {
  cat <<EOF
${YELLOW}usage: deploy.sh [options]${RESET}

${GREEN}-c file     ${RESET}Path to deploy config file.
            Default: deployconfig.env
            (i) Can be set via environment variable 'DEPLOY_CONFIG'
${GREEN}-s dir      ${RESET}Source directory to upload.
            Default: web/
            (i) Can be set via environment variable 'SOURCE_DIR'
${GREEN}-S dir      ${RESET}Static resources directory copied into the source dir before build.
            Default: static_resources/
            (i) Can be set via environment variable 'STATIC_DIR'
${GREEN}-B          ${RESET}Skip the build step (do not call build.sh).
${GREEN}-k          ${RESET}Skip compilation (bun build and tiefdownconverter) during build.
${GREEN}-n          ${RESET}Skip upload (build only).
${GREEN}-q          ${RESET}Make script quiet.
${GREEN}-v          ${RESET}Make script verbose.
${GREEN}-h          ${RESET}Show this help.
EOF
}

DEPLOY_CONFIG="${DEPLOY_CONFIG:-deployconfig.env}"
SOURCE_DIR="${SOURCE_DIR:-web/}"
STATIC_DIR="${STATIC_DIR:-static_resources/}"
unset -v SKIP_BUILD
unset -v SKIP_COMPILE
unset -v SKIP_UPLOAD
unset -v QUIET
unset -v VERBOSE

while getopts "c:s:S:Bknqvh" opt; do
  case $opt in
    c) DEPLOY_CONFIG=$OPTARG ;;
    s) SOURCE_DIR=$OPTARG ;;
    S) STATIC_DIR=$OPTARG ;;
    B) SKIP_BUILD=YES ;;
    k) SKIP_COMPILE=YES ;;
    n) SKIP_UPLOAD=YES ;;
    q) QUIET=YES ;;
    v) VERBOSE=YES ;;
    h) info; exit 0 ;;
    \?) echo "Use -h for help"; exit 1 ;;
  esac
done

if [ ! -f "$DEPLOY_CONFIG" ]; then
  error_echo "Deploy config '$DEPLOY_CONFIG' not found. Copy deployconfig.env.example to deployconfig.env and fill in your server details." 1
fi

if [ ! -d "$SOURCE_DIR" ]; then
  error_echo "Source directory '$SOURCE_DIR' does not exist." 1
fi

if [ -z "$SKIP_BUILD" ]; then
  build_args=(-s "$SOURCE_DIR" -S "$STATIC_DIR")
  [ -n "$SKIP_COMPILE" ] && build_args+=(-k)
  [ -n "$QUIET" ]        && build_args+=(-q)
  [ -n "$VERBOSE" ]      && build_args+=(-v)
  "$SCRIPT_DIR/build.sh" "${build_args[@]}"
else
  normal_echo "${YELLOW}Skipping build due to -B option.${RESET}"
fi

# shellcheck source=/dev/null
source "$DEPLOY_CONFIG"

if [ -z "$SERVER_HOST" ] || [ -z "$REMOTE_PATH" ]; then
  error_echo "Config '$DEPLOY_CONFIG' must define SERVER_HOST and REMOTE_PATH." 1
fi

if [ -z "$SKIP_UPLOAD" ]; then
  rsync_args=(
    --archive
    --compress
    --delete
    --checksum
    --human-readable
  )

  if [ "$VERBOSE" ]; then
    rsync_args+=(--verbose)
  fi

  ssh_cmd="ssh"
  [ -n "$SERVER_PORT" ] && ssh_cmd="$ssh_cmd -p $SERVER_PORT"
  [ -n "$IDENTITY" ]    && ssh_cmd="$ssh_cmd -i $IDENTITY"
  rsync_args+=(--rsh "$ssh_cmd")

  if [ -n "$SERVER_USER" ]; then
    rsync_dest="${SERVER_USER}@${SERVER_HOST}:${REMOTE_PATH}"
  else
    rsync_dest="${SERVER_HOST}:${REMOTE_PATH}"
  fi

  normal_echo "${CYAN}Deploying '$SOURCE_DIR' to ${rsync_dest}...${RESET}"

  rsync "${rsync_args[@]}" "$SOURCE_DIR" "$rsync_dest" \
    > >(verbose_echo_stdin "rsync") \
    2> >(normal_echo_stderr "${RED}rsync (error)")
  rsync_status=$?

  if [ $rsync_status -ne 0 ]; then
    error_echo "rsync exited with status code ${rsync_status}." "$rsync_status"
  fi

  normal_echo "${GREEN}Deploy complete.${RESET}"
else
  normal_echo "${YELLOW}Skipping upload due to -n option.${RESET}"
fi
