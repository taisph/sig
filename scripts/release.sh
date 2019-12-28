#!/usr/bin/env bash

set -eu

project_name="${1?}"
tag_name="${2?}"

assets=()
while read -r filename label; do
  assets+=( -a "${filename}#${label}" )
done

if hub release --include-drafts | grep -q "^${tag_name}\$"; then
  hub release edit "$tag_name" --message "" "${assets[@]}"
else
  {
    echo -e "${project_name} ${tag_name#v}\n"
    scripts/changelog.sh
  } | hub release create --draft --file - "$tag_name" "${assets[@]}"
fi
