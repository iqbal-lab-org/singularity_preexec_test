#!/usr/bin/env bash
set -e

timeout_length=60s

help="Usage: $0 [options] <file/dir names to check exist>

Checks directories are visible from inside singularity container.  Uses
'timeout' command to give up after set period of time.

Options:
  -h    Show this help and exit
  -t    String passed to timeout command [$timeout_length]
  -x    Be more verbose by setting the bash -x option

Example - look for 'foo' and 'bar'. Give up after 42 seconds:
  $0 -t 42s foo bar
"


OPTIND=1

while getopts "ht:x" opt; do
    case "$opt" in
    h)  echo "$help"
        exit 0
        ;;
    t)  timeout_length=$OPTARG
        ;;
    x)  set -x
        ;;
    esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift

if [ $# -lt 1 ]; then
    >&2 echo "Error: must provide at least one file/directory name to look for"
    exit 1
fi

# See https://stackoverflow.com/questions/59895/how-to-get-the-source-directory-of-a-bash-script-from-within-the-script-itself
this_script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
simg=$this_script_dir/alpine.simg
timeout $timeout_length singularity exec $simg ls $@
