#!/bin/bash

case "$1" in
  help|?|-h|--help)
    echo "Available Commands:"
    echo "  bb:          Build all images inside curated image folder. Honors SKIP."
    echo "  bi:          List images inside a folder."
    echo "  bm:          List module names inside a folder."
    echo "  xdrun:       Run a Docker image. You can pass a command (default is sh)."
    echo "  xdrune:      Run a Docker image, suppressing the entrypoint. You can pass a command (default is sh)."
    echo "  xdex:        Exec into a running container."
    echo "  xdi:         List Docker images. You can pass a search string."
    echo "  xdrm:        Delete Docker images based on a search string. Supports -f."
    echo "  xf:          Fancy search string & open file inside preview & vi for quick copy-paste."
    echo "  xglog:       Fancy Git commit browser."
    echo "  xgdiff:      Fancy Git diff viewer."
    echo "  get_dockerfile.sh: Generate a Dockerfile from an image."
    echo "  export_image.sh:   Export Docker image filesystem."
    echo "  pull_curated: Pull curated image from Quay. Handy if Docker build fails due to dependency image issues."
    echo
    ;;
  *)
    echo "No help requested."
    ;;
esac

unalias bb &> /dev/null

rm -vf /usr/local/bin/b?
rm -f /usr/local/bin/xg*
rm -f /usr/local/bin/xd*
rm -f /usr/local/bin/xf*

cmds="bb  bi  bm  clean_containers.sh  export_image.sh  get_dockerfile.sh  xdex  xdi  xdrm  xdrun  xdrune  xf  xgdiff  xglog  xgtag"

for cmd in $cmds; do
    ln -svf /root/rapidfort/functional-tests/helpers/$cmd /usr/local/bin/$cmd
done

ln -svf /root/rapidfort/functional-tests/devops/pull_curated_images.sh /usr/local/bin/pull_curated
