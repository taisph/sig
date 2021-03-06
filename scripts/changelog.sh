#!/usr/bin/env bash

set -eu

head="${1:-HEAD}"

for sha in $(git rev-list -n 100 --first-parent "$head"^); do
  previous_tag="$(git tag -l --points-at "$sha" '*' 2>/dev/null || true)"
  [ -z "$previous_tag" ] || break
done

if [ -z "$previous_tag" ]; then
  echo "Couldn't detect previous version tag" >&2
  exit 1
fi

git log --no-merges --format='%C(auto,green)* %s%C(auto,reset)%n%w(0,2,2)%+b' \
  --reverse "${previous_tag}..${head}" -- $(find . -name '*.go' ! -name '*_test.go')
