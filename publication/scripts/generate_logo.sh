#!/bin/sh
set -eu

publication_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
source_argument=${1:?SVG source path is required}
output_argument=${2:?PDF output path is required}

case "$source_argument" in
  /*) source_file=$source_argument ;;
  *) source_file="$publication_dir/$source_argument" ;;
esac

case "$output_argument" in
  /*) output_file=$output_argument ;;
  *) output_file="$publication_dir/$output_argument" ;;
esac

temporary_file="${output_file}.tmp.pdf"

if ! command -v rsvg-convert >/dev/null 2>&1; then
    echo "Vector logo generation requires rsvg-convert (librsvg)." >&2
    exit 1
fi

mkdir -p "$(dirname -- "$output_file")"
rsvg-convert --format=pdf1.5 --keep-aspect-ratio --output="$temporary_file" "$source_file"
mv "$temporary_file" "$output_file"
