$ErrorActionPreference = "Stop"

$mmdc = Get-Command mmdc.cmd -ErrorAction SilentlyContinue
if (-not $mmdc) {
    $mmdc = Get-Command mmdc -ErrorAction SilentlyContinue
}
if (-not $mmdc) {
    throw "Mermaid CLI not found. Install it with: npm install -g @mermaid-js/mermaid-cli"
}

Get-ChildItem -LiteralPath $PSScriptRoot -Filter *.mmd | ForEach-Object {
    $output = Join-Path $PSScriptRoot ($_.BaseName + ".svg")
    & $mmdc.Source -i $_.FullName -o $output -b transparent
}
