#!/bin/sh

usage() {
  echo "Usage: $0 <action> "
  echo "Actions:"
  echo "  build "
  echo "  run "
  echo "  exec "
  echo "  stop"
}

if [ "$#" -lt 1 ]; then
  usage
  exit 1
fi

action="$1"
shift

case "$action" in
  build)
    docker build -t yy354/cascade_docker:v1.0 --build-arg GITHUB_TOKEN=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 .
    ;;
  run)
    docker run -P --privileged -d -it --name=alicasenv yy354/cascade_docker:v1.0
    ;;
  exec)
    docker exec -it -u0  alicasenv bash
    ;;
  stop)
    docker stop alicasenv
    docker rm alicasenv
    ;;
  *)
    usage
    exit 1
    ;;
esac
