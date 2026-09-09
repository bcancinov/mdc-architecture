#!/bin/sh
set -eu

source_file="../decisions/ADR-003_state_machine_definition.md"
output_file="handbook/generated/shared_signals.tex"
temporary_file="${output_file}.tmp"

awk '
  function trim(value) {
    sub(/^[[:space:]]+/, "", value)
    sub(/[[:space:]]+$/, "", value)
    return value
  }
  function escape(value) {
    gsub(/`/, "", value)
    gsub(/&/, "\\&", value)
    gsub(/%/, "\\%", value)
    gsub(/#/, "\\#", value)
    gsub(/_/, "\\_", value)
    gsub(/\$/, "\\$", value)
    return value
  }
  BEGIN {
    in_table = 0
    count = 0
    print "% Generated from ADR-003 R3. Do not edit."
    print "\\newcommand{\\GeneratedSharedSignalRows}{%"
  }
  $0 == "| Signal | Driver and topology | Architectural behavior |" { in_table = 1; next }
  in_table && /^\|---/ { next }
  in_table && /^\|/ {
    split($0, field, "|")
    signal = escape(trim(field[2]))
    driver = escape(trim(field[3]))
    behavior = escape(trim(field[4]))
    printf "\\texttt{%s} & %s & %s \\\\\n", signal, driver, behavior
    count++
    next
  }
  in_table { in_table = 0 }
  END {
    if (count != 6) {
      print "Expected six shared-signal rows in ADR-003 R3" > "/dev/stderr"
      exit 1
    }
    print "}"
  }
' "$source_file" > "$temporary_file"

mv "$temporary_file" "$output_file"
