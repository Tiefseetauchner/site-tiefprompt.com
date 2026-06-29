#!/bin/bash
set -e 

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
${GREEN}-S dir      ${RESET}Static resources directory copied into the source dir before deploy.
            Default: static_resources/
            (i) Can be set via environment variable 'STATIC_DIR'
${GREEN}-q          ${RESET}Make script quiet.
${GREEN}-v          ${RESET}Make script verbose.
${GREEN}-h          ${RESET}Show this help.
EOF
}

DEPLOY_CONFIG="${DEPLOY_CONFIG:-deployconfig.env}"
SOURCE_DIR="${SOURCE_DIR:-web/}"
STATIC_DIR="${STATIC_DIR:-static_resources/}"
unset -v QUIET
unset -v VERBOSE

while getopts "c:s:S:qvh" opt; do
  case $opt in
    c) DEPLOY_CONFIG=$OPTARG ;;
    s) SOURCE_DIR=$OPTARG ;;
    S) STATIC_DIR=$OPTARG ;;
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

if [ -d "$STATIC_DIR" ]; then
  normal_echo "${CYAN}Copying static resources from '$STATIC_DIR' to '$SOURCE_DIR'...${RESET}"
  cp -a "${STATIC_DIR%/}/." "$SOURCE_DIR"
fi

# shellcheck source=/dev/null
source "$DEPLOY_CONFIG"

if [ -z "$SERVER_HOST" ] || [ -z "$REMOTE_PATH" ]; then
  error_echo "Config '$DEPLOY_CONFIG' must define SERVER_HOST and REMOTE_PATH." 1
fi

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
