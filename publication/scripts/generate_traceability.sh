#!/bin/sh
set -eu

output_file="handbook/generated/traceability.tex"
temporary_file="${output_file}.tmp"

awk '
  function contents(line) {
    sub(/^[^{]*\{/, "", line)
    sub(/\}[[:space:]]*$/, "", line)
    return line
  }
  FNR == 1 {
    filename = FILENAME
    sub(/^.*\//, "", filename)
    chapter_number = substr(filename, 1, 2) + 0
    chapter_title = ""
    chapter_label = ""
  }
  /^\\chapter\{/ { chapter_title = contents($0); next }
  /^\\label\{chap:/ { chapter_label = contents($0); next }
  /^% Traceability:/ {
    sources = $0
    sub(/^% Traceability:[[:space:]]*/, "", sources)
    display = sources
    gsub(/[[:space:]]+/, ", ", display)
    forward[chapter_number] = "\\hyperref[" chapter_label "]{Chapter " chapter_number " --- " chapter_title "} & " display " \\\\"
    count = split(sources, source, /[[:space:]]+/)
    for (item = 1; item <= count; item++) {
      id = source[item]
      reference = "\\hyperref[" chapter_label "]{Chapter " chapter_number "}"
      reverse[id] = reverse[id] (reverse[id] == "" ? "" : ", ") reference
    }
  }
  END {
    print "% Generated from Traceability declarations in handbook chapters. Do not edit."
    print "\\newcommand{\\GeneratedForwardTraceabilityRows}{%"
    for (chapter = 1; chapter <= 9; chapter++) {
      if (forward[chapter] == "") {
        print "Missing traceability for Chapter " chapter > "/dev/stderr"
        exit 1
      }
      print forward[chapter]
    }
    print "}"
    print "\\newcommand{\\GeneratedReverseTraceabilityRows}{%"
    for (number = 1; number <= 6; number++) {
      id = sprintf("ADR-%03d", number)
      if (reverse[id] == "") {
        print "Missing reverse traceability for " id > "/dev/stderr"
        exit 1
      }
      print id " & " reverse[id] " \\\\"
    }
    print "}"
  }
' handbook/chapters/0[1-9]_*.tex > "$temporary_file"

mv "$temporary_file" "$output_file"
