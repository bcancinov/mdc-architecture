#!/bin/sh
set -eu

log_file=${1:?LaTeX log path is required}
pdf_file=${2:?PDF path is required}

test -s "$log_file"
test -s "$pdf_file"

if grep -E '(^! |LaTeX Error|undefined references|Citation .+ undefined|Reference .+ undefined)' "$log_file"; then
    echo "Build check failed: LaTeX errors or unresolved references were found." >&2
    exit 1
fi

if grep -E '(Overfull|Underfull) \\hbox' "$log_file"; then
    echo "Build check failed: text does not fit its intended line or table column." >&2
    exit 1
fi

if grep -Fq 'PDF inclusion:' "$log_file"; then
    echo "Build check failed: an included PDF is incompatible with the output version." >&2
    exit 1
fi

pdfinfo "$pdf_file" | grep -E '^(Title|Author|Creator|Pages|Page size):'

publication_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
expected_version=$(sed -n 's/.*\\NOIRLabVersion}{\([^}]*\)}.*/\1/p' "$publication_dir/metadata.tex")
test -n "$expected_version"
pdftotext "$pdf_file" - | grep -Fq "Version: $expected_version"
pdftotext "$pdf_file" - | grep -Fq 'derived and non-normative'
pdftotext "$pdf_file" - | grep -Fq 'Generation date'

if grep -R -q '\\HandbookPlaceholder' handbook/chapters handbook/appendices; then
    echo "Build check failed: handbook placeholders remain." >&2
    exit 1
fi

echo "Non-visual handbook checks passed."
