# Architecture Handbook Publication

This directory contains the derived, non-normative architecture handbook. The [system concept guide](../integration/system_concept_guide.md) is the maintained explanatory content source. Handbook chapters expand it and are kept aligned manually; there is no automatic Markdown-to-LaTeX prose conversion. Resolved ADRs under `../decisions/` remain authoritative.

## Compile the handbook

Install a TeX distribution containing LuaLaTeX, `latexmk`, and Biber (for example MiKTeX on Windows, MacTeX on macOS, or TeX Live on Windows/Linux). The bibliography, style, and TikZ dependencies must also be installed; see the platform notes below.

From the repository root:

```sh
cd publication
latexmk -jobname=modular-detector-controller-architecture handbook/main.tex
```

Run the command from `publication/` so `latexmkrc` and all relative paths resolve. It rebuilds changed TikZ figures, processes the bibliography, and repeats LaTeX until references settle. No separate figure-build command is needed.

The output is:

```text
publication/build/modular-detector-controller-architecture.pdf
```

The matching `.log` in `build/` contains compiler diagnostics. `latexmk handbook/main.tex` also works, but produces `build/main.pdf`; use the named command above for the normal handbook output.

The document version, revision date, and change summary are maintained in `metadata.tex`. Version 0.2 remains a working version. The generation date reflects the day of compilation; the revision date records the content revision. Keep previous entries in the front-matter change record when adding a later version.

### Windows with MiKTeX

1. Install MiKTeX using the [official Windows installation instructions](https://miktex.org/howto/install-miktex). A per-user installation is suitable for a normal workstation.
2. Open **MiKTeX Console**, check for updates, and apply them. In its settings, enable automatic installation of missing packages, or approve installation prompts during the first build. See [MiKTeX Console package management](https://miktex.org/howto/miktex-console).
3. Install [Strawberry Perl](https://strawberryperl.com/) if Perl is not already available. `latexmk` requires a Perl interpreter. Close and reopen PowerShell and your editor after installation so they pick up the updated `PATH`.
4. Ensure MiKTeX has `latexmk`, LuaLaTeX, and Biber available. Missing TeX packages can be installed through MiKTeX Console. The handbook uses KOMA-Script, TikZ/PGF, `standalone`, `fontspec`, Source Sans Pro, `microtype`, `currfile`, and `biblatex`, among other dependencies; automatic package installation resolves the remaining requirements.

In a new **PowerShell** window, check that the tools are available:

```powershell
perl --version
latexmk -v
lualatex --version
biber --version
```

Replace the example path below with your local checkout. Quoting it allows spaces in directory names:

```powershell
Set-Location "C:\path\to\specifications\publication"
latexmk -jobname=modular-detector-controller-architecture handbook/main.tex
if ($LASTEXITCODE -ne 0) { throw "Handbook compilation failed; inspect the build log." }
Start-Process ".\build\modular-detector-controller-architecture.pdf"
```

The same `latexmkrc` handles LuaLaTeX, bibliography passes, and figure builds on Windows. Run this command from `publication`, not from `handbook`. WSL, Bash, and Make are not required for this build. An editor should use LuaLaTeX through `latexmk` and the same working directory.

If a command is not found, confirm that MiKTeX's executable directory and Perl's executable directory are on `PATH`, then reopen the terminal. If `latexmk` reports a missing Perl script engine, complete the Perl installation before retrying.

If LuaLaTeX reports an unwritable font cache, use this PowerShell fallback from `publication`:

```powershell
New-Item -ItemType Directory -Force ".\build\texmf-cache" | Out-Null
$env:TEXMFCACHE = (Resolve-Path ".\build\texmf-cache").Path
$env:TEXMFVAR = $env:TEXMFCACHE
latexmk -jobname=modular-detector-controller-architecture handbook/main.tex
```

These environment settings apply to the current PowerShell session. If an earlier figure failure is cached, follow the figure auxiliary-file cleanup instructions below after correcting its cause.

The optional `.sh` maintenance and validation scripts are separate from compilation. On Windows, run them in a Bash environment with the required utilities available (including `awk`, and Poppler for PDF checks), or use a configured WSL toolchain. They cannot be pasted directly into PowerShell. Windows/MiKTeX execution has not been tested in this macOS workspace.

### Non-visual verification

From `publication/`, after compilation:

```sh
sh scripts/check_build.sh \
  build/modular-detector-controller-architecture.log \
  build/modular-detector-controller-architecture.pdf
```

This requires Poppler's `pdfinfo` and `pdftotext` in addition to the TeX tools. It checks compilation errors, unresolved references/citations, text-box warnings, PDF compatibility, and version metadata. It does not visually inspect diagrams or guarantee layout quality. Visual review remains with the reader.

### Updating the source content

1. Update architectural requirements in their owning ADR when a decision changes.
2. Keep `integration/system_concept_guide.md` and the corresponding `handbook/chapters/` explanations aligned. The guide is the explanatory source; the chapters expand it for publication.
3. Edit diagram content in `figures/source/`. Link the generated figure from the guide when it illustrates the same explanation. The example function board is `example_function_board.tikz.tex`.
4. Regenerate affected shared tables using the maintenance commands below, from `publication/`.
5. Update publication metadata/change history, compile, and run non-visual checks. Review the PDF visually separately.

### Troubleshooting a restricted font cache

If LuaLaTeX reports `no writeable cache path`, give it a writable cache directory. For macOS/Linux shells, run from `publication/`:

```sh
mkdir -p build/texmf-cache
TEXMFCACHE="$PWD/build/texmf-cache" TEXMFVAR="$PWD/build/texmf-cache" \
  latexmk -jobname=modular-detector-controller-architecture handbook/main.tex
```

The first use may take longer while LuaLaTeX builds its font database. On Windows, set `TEXMFCACHE` and `TEXMFVAR` to a writable directory using the shell's environment-variable syntax before running the same `latexmk` command. If a previous figure failure is cached, remove only that figure's auxiliary files as described below and rebuild after correcting the cause.

### Platform notes

- **Editors.** TeXstudio, TeXworks, and the VS Code LaTeX Workshop extension all drive `latexmk`. Set the recipe to `latexmk` with LuaLaTeX, or open this directory and build the default recipe.
- **MiKTeX.** `latexmk` is a Perl script and MiKTeX does not always supply Perl. If `latexmk` reports that Perl is missing, install Strawberry Perl, or use TeX Live for Windows, which bundles its own Perl.
- **Missing packages.** MiKTeX installs them on demand the first time you build. On TeX Live and MacTeX, use the full scheme, or install `koma-script`, `sourcesanspro`, `microtype`, `currfile`, `biblatex`, and `biber`.
- The build must be run from this directory, so that `latexmkrc` and the relative paths to `latex/noirlab/` resolve.

### Editing figures

Figures need no separate command. `latexmkrc` brings them up to date before the document is built, and a figure is recompiled only when its source in `figures/source/` has changed. Editing a figure and running the ordinary build is enough:

```sh
latexmk handbook/main.tex
```

A build with no figure edits does no TikZ work; the up-to-date check costs well under a second. The set of figures is found by pattern rather than listed anywhere, so a newly added source is picked up with no configuration. Nothing watches the filesystem: figures are rebuilt when this command is run, and at no other time.

The document reads the PDFs in `figures/generated/`. Commit the regenerated PDFs together with the source change, so a fresh checkout and Overleaf build without recompiling anything.

Each figure source is also a complete standalone document. Compiling one on its own requires `noirlab-document.sty` to be on `TEXINPUTS`, which `latexmkrc` sets for the build; a bare `latexmk -norc` on a single figure skips that file and will not find the style.

If a figure fails to compile, `latexmk` records the failure and later document builds stop with `gave an error in previous invocation`. Clear it by deleting that figure's `.aux`, `.fdb_latexmk`, `.fls`, and `.log` from `figures/generated/`.

### Maintenance commands

There is no build system to invoke; these scripts are run directly and are only needed for the tasks named. They require a Unix shell and `awk`, so they are maintainer tools on macOS or Linux rather than part of the build. Building and editing the handbook, including its figures, needs none of them.

```sh
./scripts/generate_glossary.sh         # after editing the vocabulary table in ../README.md
./scripts/generate_shared_signals.sh   # after editing ADR-003
./scripts/generate_utility_rails.sh    # after editing ADR-005
./scripts/generate_traceability.sh     # after editing the chapters

# Formal release only (not required for working version 0.2):
./scripts/check_release.sh             # requires release metadata and a clean repository

# non-visual checks on a build made with the released job name
./scripts/check_build.sh \
  build/modular-detector-controller-architecture.log \
  build/modular-detector-controller-architecture.pdf

latexmk -C -jobname=modular-detector-controller-architecture handbook/main.tex  # clean named build
```

The fragments under `handbook/generated/` are committed, so regenerating them is part of a change to their sources, not a step every reader has to run.

Working builds display the document version and generation date without a draft watermark. Both come from `metadata.tex`.

## Source organization

- `../integration/system_concept_guide.md` supplies the maintained explanatory content; chapter prose is synchronized manually.
- `metadata.tex` is the single maintained source for publication-control metadata.
- `handbook/chapters/` and `handbook/appendices/` contain derived explanatory sources.
- `latex/noirlab/` is the self-contained, reusable NOIRLab LaTeX package and the single source for document presentation, including diagram conventions. It is maintained as its own repository and carries its own README; nothing handbook-specific belongs in it. `latex/architecture.sty` contains only handbook-specific bibliography configuration and metadata validation.
- `latex/noirlab/noirlab-assets/` contains the NOIRLab and AURA vector identity assets used by the reusable style; maintained SVG originals are under its `source/` directory.
- `handbook/generated/` contains fragments derived from the ADRs and `../README.md`, so the glossary, traceability matrix, shared-signal list, and utility-rail table cannot drift from the documents that control them. The files are committed; regenerate them with the scripts above when their sources change.
- `figures/source/` contains maintained TikZ figure content and geometry; `figures/generated/` contains the committed PDF derivatives. Their shared visual conventions come from `latex/noirlab/noirlab-document.sty`.

## Review boundary

Automated checks cover compilation, unresolved references and citations, version and generation metadata, and textual PDF properties. The user owns all visual review. The assistant does not render or visually inspect the PDF unless the user explicitly changes that instruction.

Before a formal public release, record the exact logo download URLs and verify the NOIRLab and AURA identity assets against the current visual-identity guidance.
