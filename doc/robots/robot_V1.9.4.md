# LuaLaTeX Climbing Guidebook Engine: System Documentation & Architecture Manual

> **AI Ingestion Schema & Developer Guide (Version 1.9.4 Specs)**
> *Target System:* Hybrid LuaLaTeX (`expl3`, `luatex`) + POSIX CI/CD Pipeline + Python Asset Generator.

---

## 1. Top-Level Directory Structure & Module Responsibilities

The project enforces an absolute decoupling between the presentation layer (\LaTeX), the data/logic layer (Lua), and external asset generation (Python). Production source files remain purely declarative databases with explicit relative paths.

<ProjectStructure>
    <Directory path="src/" role="Core Engine">
        <Description>Decoupled backend logic and frontend presentation modules, consolidated by domain.</Description>
        <File name="climbingguide.sty">Master package loader, global formatting tolerances, and input buffer U+00A0 sanitizer.</File>
        <File name="climbingguide.lua">AST state manager, route registration, and LaTeX-Lua bridge.</File>
        <File name="cg-theme.sty">Consolidated Domain: Design tokens, color matrices, explicit pt-sized semantic font aliases, and physical page geometry.</File>
        <File name="cg-header.sty">Domain: Two-sided running header/footer and page style management.</File>
        <File name="cg-components.sty">Consolidated Domain (Pure LaTeX2e): Frontend visual macros, TikZ positioning, layout containers, responsive route badges, and QR code rendering.</File>
        <File name="cg-frontmatter.sty">Domain: Asymmetric layouts, cover builder, and native ToC styling.</File>
        <File name="cg-backmatter.sty">Domain: Generic backmatter chapters and decoupled alphabetical/grade list generators.</File>
        <File name="cg-engine.sty">Domain (LaTeX3/expl3): State tracking pipeline, global counters, and the auxiliary triggers connecting to Lua.</File>
        <File name="export_json.lua">RFC 8259-compliant Unicode control character hex-serializer.</File>
        <File name="export_txt.lua">Fixed-delimiter schema writer with N/A padding.</File>
        <File name="route_sorter.lua">Pure functional module enforcing Strict Weak Ordering and accent normalization.</File>
        <File name="sanitize_tex.lua">Lexical parser validating brace depth and stripping TeX macros.</File>
        <File name="zone_stats.lua">In-memory tier aggregation and TikZ grade distribution bar chart rendering.</File>
        <File name="qr_manager.lua">Parses URLs, extracts deterministic IDs, and serializes state to export/qrcodes_manifest.json.</File>
    </Directory>

    <Directory path="production/" role="User Database">
        <Description>Declarative guidebook database containing only data and layout flow macros.</Description>
        <File name="serra_do_cuo.tex">Master document. Sets global headers and ingests zone files via EXPLICIT paths (e.g., \input{production/production_tex/...}).</File>
        <File name="production_tex/">Directory housing all structural modules (frontmatter, endmatter, zones).</File>
    </Directory>

    <Directory path="scripts/python/" role="External Asset Generation">
        <Description>Isolated Python environment (.venv) for generating dynamic assets.</Description>
        <File name="generate_qrcodes.py">Idempotent script using `segno` to read the Lua JSON manifest and generate high-resolution PNG QR codes.</File>
    </Directory>

    <File name="Makefile" role="Build Orchestrator">
        <Description>Manages 3-pass LuaLaTeX compilation, test suites, Python execution, and automatic *.cgstats cache purging.</Description>
    </File>
</ProjectStructure>

<PublicAPI>
    <Macro name="\CGZoneHeader">
        <Signature>\CGZoneHeader[label]{path}{name}</Signature>
        <Arguments>
            <Arg type="optional" format="[]">label: String. Places text above the title (e.g., ZONA).</Arg>
            <Arg type="mandatory" format="{}">path: String. Path to the cover image banner.</Arg>
            <Arg type="mandatory" format="{}">name: String. The name of the climbing zone.</Arg>
        </Arguments>
        <Constraints>Automatically triggers \clearpage layout. Renders cached ZoneStats bar chart and injects any pending \CGAddQRCodeToZoneHeader requests.</Constraints>
    </Macro>

    <Macro name="\CGQRCode">
        <Signature>\CGQRCode[caption]{url}{info}</Signature>
        <Arguments>
            <Arg type="optional" format="[]">caption: String. Typeset below the matrix.</Arg>
            <Arg type="mandatory" format="{}">url: String. The target hyperlink.</Arg>
            <Arg type="mandatory" format="{}">info: String. Used by Lua to generate a deterministic, collision-resistant filename.</Arg>
        </Arguments>
        <Constraints>Renders relative/inline QR codes wrapped in a minipage. Falls back to a gray placeholder if the PNG is missing during early compiler passes.</Constraints>
    </Macro>

    <Macro name="\CGAddQRCodeToZoneHeader">
        <Signature>\CGAddQRCodeToZoneHeader{url}{info}</Signature>
        <Arguments>
            <Arg type="mandatory" format="{}">url: String.</Arg>
            <Arg type="mandatory" format="{}">info: String.</Arg>
        </Arguments>
        <Constraints>Does NOT render immediately. Injects state into global expl3 token lists. Must be called exactly before \CGZoneHeader.</Constraints>
    </Macro>

    <Macro name="\CGRoute">
        <Signature>\CGRoute{name}{grade}{length}{gear}{setter}[obs]</Signature>
        <Arguments>
            <Arg type="mandatory" format="{}">name: String. Route name.</Arg>
            <Arg type="mandatory" format="{}">grade: String. Adheres to Brazilian grade logic (e.g., 7a, 4sup, 3 IVsup, Proj).</Arg>
            <Arg type="mandatory" format="{}">length: String. Height (e.g., 15m).</Arg>
            <Arg type="mandatory" format="{}">gear: String. Protection required (e.g., 3+2, Móvel).</Arg>
            <Arg type="mandatory" format="{}">setter: String. First ascencionist or setter.</Arg>
            <Arg type="optional" format="[]">obs: String. Beta, warnings, or observation text.</Arg>
        </Arguments>
        <Constraints>Must be placed strictly inside the \begin{CGSectorRoutes} environment.</Constraints>
    </Macro>
</PublicAPI>

<VersionSpec version="1.9.4">
    <Description>Layout Engine Stabilization, Python Asset Pipeline, and TOC Decoupling.</Description>
    
    <Enhancement name="Automated QR Pipeline">
        <Description>Implemented a Python-LuaLaTeX hybrid pipeline. Lua parses URLs and dumps a JSON manifest. The Makefile orchestrates a Python generator (using `segno`) to build missing PNGs natively outside of TeX's write18 limitations, allowing reliable high-resolution rasterization.</Description>
    </Enhancement>

    <Enhancement name="TikZ Absolute Coordinate Stabilization (3-Pass Compilation)">
        <Description>Resolved critical vanishing elements in `\CGZoneHeader` and `\CGIndexCorner`. Modified the Makefile to strictly enforce a 3-pass compilation. Pass 1 extracts data, Pass 2 anchors TikZ coordinates to the `.aux` file (resolving geometry changes caused by injected charts), and Pass 3 renders the visual `[remember picture, overlay]` nodes accurately.</Description>
    </Enhancement>

    <Enhancement name="Responsive Route Badges">
        <Description>Shifted the mathematical anchor of the TikZ route badge downward by `1.5ex` to achieve perfect horizontal alignment with text cap-height. Integrated `\adjustbox{max width=0.85\CGRouteBadgeSize...}` inside the badge node to dynamically scale down 3-digit route numbers, preventing layout overflow.</Description>
    </Enhancement>

    <Enhancement name="TOC Endmatter Decoupling">
        <Description>Injected a structural `\addcontentsline{toc}{part}{REFERÊNCIA}` boundary into `endmatter.tex`. This prevents backmatter sections (Geology, History, Indexes) from nesting incorrectly beneath the final climbing zone in the Table of Contents.</Description>
    </Enhancement>
</VersionSpec>

## 2. Troubleshooting History & Architecture Decisions

### Session: V1.9.4 Pipeline & Typography Enhancements

**Issue 1: False-Positive Grade Formatting Errors**
* **Root Cause:** In `src/climbingguide.lua`, the regex `%d+[ o]?[ivx]+` erroneously trapped valid grades containing spaces (e.g., "3 IVsup") because the space was included in the optional character class `[ o]?`.
* **Resolution:** Refactored the regex to `%d+o?[ivx]+`. This ensures the validation strictly targets concatenated numeric/roman characters (e.g., `3IV` or `3oIV`) without punishing valid standard spacing.

**Issue 2: Expl3 Token Runaways in Frontmatter**
* **Root Cause:** A `\CGDoubleTextSection` macro in `frontmatter.tex` was invoked with only three arguments instead of the mandatory four (`{TitleLeft}{BodyLeft}{TitleRight}{BodyRight}`). This caused the parser to break paragraph boundaries and throw an `expl3` runaway error.
* **Resolution:** Replaced the invocation with two independent, robust `\CGTextSingleColumn` blocks.

**Issue 3: Redundant Bash Sanitization**
* **Root Cause:** A legacy bash script (`scripts/clean_nbsp.sh`) was manually parsing and removing UTF-8 `\xC2\xA0` non-breaking spaces across the repository, adding unnecessary I/O overhead.
* **Resolution:** Deleted the script entirely. The engine already handles this elegantly in memory via the Lua `process_input_buffer` callback (in `climbingguide.sty`), stripping the characters before TeX tokenization.

**Issue 4: Unresolved Paths for Input Files**
* **Root Cause:** `\input{zones/zona_baixa.tex}` failed because the `production_tex` directory structure did not match the logical paths, and depending on implicit `TEXINPUTS` variables creates environment-specific fragility.
* **Resolution:** Enforced explicit pathing from the project root for all file ingestions (e.g., `\input{production/production_tex/zona_baixa.tex}`).

