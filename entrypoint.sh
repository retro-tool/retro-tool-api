#!/bin/bash
set -e

case "$1" in
  start)
    ./prod/rel/retro/bin/retro start
    ;;

  migrate)
    ./prod/rel/retro/bin/retro eval "Xrt.Release.migrate"
    ;;

  rollback)
    ./prod/rel/retro/bin/retro eval "Xrt.Release.rollback"
    ;;

  shell)
    /bin/sh
    ;;

  *)
    # This is the default in order to not break production when
    # this is deployed the first time
    ./prod/rel/retro/bin/retro start

    ;;
esac
