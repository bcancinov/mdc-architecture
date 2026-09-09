#!/bin/sh
set -eu

publication_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
repository_dir=$(git -C "$publication_dir" rev-parse --show-toplevel)
metadata_file="$publication_dir/metadata.tex"

if ! grep -Fq '\NOIRLabReleasetrue' "$metadata_file"; then
    echo "Release build refused: metadata.tex is still configured as a draft." >&2
    exit 1
fi

if grep -Eq '\\NOIRLab(ReferenceCode|DocumentOwner)\}\{Pending\}' "$metadata_file"; then
    echo "Release build refused: required controlled-document metadata is pending." >&2
    exit 1
fi

if [ -n "$(git -C "$repository_dir" status --porcelain --untracked-files=normal)" ]; then
    echo "Release build refused: the source repository is not clean." >&2
    exit 1
fi

echo "Release metadata and repository state checks passed."
