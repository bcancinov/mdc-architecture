#!/bin/sh
set -eu

source_file="../README.md"
output_file="handbook/generated/glossary.tex"
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
    print "% Generated from the Controlled vocabulary table in README.md. Do not edit."
    print "\\newcommand{\\GeneratedGlossaryRows}{%"
  }
  $0 == "| Preferred term | Meaning |" { in_table = 1; next }
  in_table && /^\|---/ { next }
  in_table && /^\|/ {
    split($0, field, "|")
    term = trim(field[2])
    meaning = trim(field[3])
    coded = (substr(term, 1, 1) == "`")
    term = escape(term)
    meaning = escape(meaning)
    if (coded)
      printf "\\texttt{%s} & %s \\\\\n", term, meaning
    else
      printf "\\textbf{%s} & %s \\\\\n", term, meaning
    count++
    next
  }
  in_table { in_table = 0 }
  END {
    if (count < 10) {
      print "Controlled vocabulary table was not extracted" > "/dev/stderr"
      exit 1
    }
    print "}"
  }
' "$source_file" > "$temporary_file"

mv "$temporary_file" "$output_file"
