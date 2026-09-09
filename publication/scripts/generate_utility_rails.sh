#!/bin/sh
set -eu

source_file="../decisions/ADR-005_backplane_utility_voltages.md"
output_file="handbook/generated/utility_rails.tex"
temporary_file="${output_file}.tmp"

awk '
  BEGIN {
    in_table = 0
    count = 0
    print "\\providecommand{\\GeneratedUtilityRailRows}{%"
  }
  $0 == "| Rail | Intended use |" { in_table = 1; next }
  in_table && /^\|---/ { next }
  in_table && /^\|/ {
    split($0, field, "|")
    rail = field[2]
    purpose = field[3]
    sub(/^[[:space:]]+/, "", rail)
    sub(/[[:space:]]+$/, "", rail)
    sub(/^[[:space:]]+/, "", purpose)
    sub(/[[:space:]]+$/, "", purpose)
    gsub(/`/, "", rail)
    gsub(/_/, "\\_", rail)
    printf "\\texttt{%s} & %s \\\\\n", rail, purpose
    count++
    if (count == 4) exit
  }
  END {
    if (count != 4) {
      print "Expected four utility rails in ADR-005" > "/dev/stderr"
      exit 1
    }
    print "}"
  }
' "$source_file" > "$temporary_file"

mv "$temporary_file" "$output_file"
