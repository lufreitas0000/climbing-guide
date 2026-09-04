# LuaLaTeX Climbing Guidebook Engine: System Documentation & Architecture Manual

> **AI Ingestion Schema & Developer Guide (Version 1.9.2 Specs)**
> *Target System:* Hybrid LuaLaTeX (`expl3`, `luatex`) + POSIX CI/CD Pipeline.

---

## 1. Top-Level Directory Structure & Module Responsibilities

The project enforces an absolute decoupling between the presentation layer (\LaTeX) and the data/logic layer (Lua). Production source files remain purely declarative databases with zero manual spacing, hardcoded breaks, or visual overrides.

<ProjectStructure>
    <Directory path="src/" role="Core Engine">
        <Description>Decoupled backend logic and frontend presentation modules, consolidated by domain.</Description>
        <File name="climbingguide.sty">Master package loader, global formatting tolerances, and input buffer U+00A0 sanitizer.</File>
        <File name="climbingguide.lua">AST state manager, route registration, and LaTeX-Lua bridge.</File>
        <File name="cg-theme.sty">Consolidated Domain: Design tokens, color matrices, explicit pt-sized semantic font aliases, and physical page geometry.</File>
        <File name="cg-header.sty">Domain: Two-sided running header/footer and page style management.</File>
        <File name="cg-components.sty">Consolidated Domain (Pure LaTeX2e): Frontend visual macros, TikZ positioning, layout containers, and image sizing wrappers.</File>
        <File name="cg-frontmatter.sty">Domain: Asymmetric layouts, cover builder, and native ToC styling.</File>
        <File name="cg-backmatter.sty">Domain: Generic backmatter chapters (history, geology, ethics) and decoupled alphabetical/grade list generators.</File>
        <File name="cg-engine.sty">Domain (LaTeX3/expl3): State tracking pipeline, global counters, and the auxiliary triggers connecting to Lua.</File>
        <File name="cg-date.lua">Pure Lua date formatting utility for localized timestamp generation.</File>
        <File name="export_json.lua">RFC 8259-compliant Unicode control character hex-serializer.</File>
        <File name="export_txt.lua">Fixed-delimiter schema writer with N/A padding.</File>
        <File name="route_sorter.lua">Pure functional module enforcing Strict Weak Ordering and accent normalization.</File>
        <File name="sanitize_tex.lua">Lexical parser validating brace depth and stripping TeX macros.</File>
        <File name="zone_stats.lua">In-memory tier aggregation and TikZ grade distribution bar chart rendering.</File>
    </Directory>

    <Directory path="production/" role="User Database">
        <Description>Declarative guidebook database containing only data and layout flow macros.</Description>
        <File name="serra_do_cuo.tex">Master document. Sets global headers and ingests zone files.</File>
        <File name="frontmatter.tex">Introduction, history, and the \CGZoneStats{Global} aggregated chart.</File>
        <File name="endmatter.tex">Geology, history, ethics chapters, and route indexes.</File>
        <Directory path="zones/">Individual .tex files containing \CGSectorRoutes environments.</Directory>
        <Directory path="images/">Contains 'covers' (full page banners) and 'topos' (route line images).</Directory>
    </Directory>

    <Directory path="tests/" role="Test-Driven Development">
        <Description>Isolated unit tests for Lua mathematical logic, sanitization, and sorting invariants.</Description>
    </Directory>

    <Directory path="scripts/" role="CI/CD Pipeline">
        <File name="clean_nbsp.sh">Perl script stripping invisible U+00A0 clipboard spaces.</File>
        <File name="parse_logs.sh">Scrapes lualatex .log files for fatal errors.</File>
        <File name="check_fonts.sh">Audits system font presence.</File>
    </Directory>

    <File name="Makefile" role="Build Orchestrator">
        <Description>Manages multi-pass compilation, test suites, and automatic *.cgstats cache purging.</Description>
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
        <Constraints>Automatically triggers \clearpage layout. Renders cached ZoneStats bar chart natively.</Constraints>
    </Macro>

    <Macro name="\CGSectorHeader">
        <Signature>\CGSectorHeader[label]{color}{name}</Signature>
        <Arguments>
            <Arg type="optional" format="[]">label: String. Defaults to SETOR. Places text above the title.</Arg>
            <Arg type="mandatory" format="{}">color: String. Must match a Color id from ColorMatrix (e.g., guide_purple).</Arg>
            <Arg type="mandatory" format="{}">name: String. The name of the sector.</Arg>
        </Arguments>
        <Constraints>Automatically renders the diagonal summary blocks based on the previous compilation cache.</Constraints>
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

    <Macro name="\CGBackmatterChapter">
        <Signature>\CGBackmatterChapter[cols]{title}{body}</Signature>
        <Arguments>
            <Arg type="optional" format="[]">cols: Integer. Number of columns (defaults to 1).</Arg>
            <Arg type="mandatory" format="{}">title: String. Chapter heading.</Arg>
            <Arg type="mandatory" format="{}">body: String / LaTeX blocks. Chapter text content.</Arg>
        </Arguments>
        <Constraints>Renders generic backmatter sections (history, geology, ethics) supporting single or multi-column layouts.</Constraints>
    </Macro>

    <Macro name="\CGPrintAlphaList">
        <Signature>\CGPrintAlphaList</Signature>
        <Constraints>Invokes Lua backend to render alphabetical route index via longtable.</Constraints>
    </Macro>

    <Macro name="\CGPrintGradeList">
        <Signature>\CGPrintGradeList</Signature>
        <Constraints>Invokes Lua backend to render grade-sorted route index via longtable.</Constraints>
    </Macro>
</PublicAPI>

<VersionSpec version="1.9.2">
    <Description>Backmatter architectural decoupling and VS Code environment stabilization.</Description>
    
    <Enhancement name="Backmatter Module Decoupling">
        <Description>Extracted \CGPrintAlphaList and \CGPrintGradeList from cg-components.sty into a dedicated cg-backmatter.sty module adhering to the Single Responsibility Principle. Introduced \CGBackmatterChapter to cleanly render generic chapters (geology, history, ethics) with flexible single or multi-column support.</Description>
    </Enhancement>

    <Enhancement name="VS Code LaTeX Workshop Integration">
        <Description>Configured relative Kpathsea search paths (TEXINPUTS and LUAINPUTS) in workspace settings, enabling robust compilation from subdirectories and establishing native user command intellisense autocomplete and hover documentation.</Description>
    </Enhancement>
</VersionSpec>

## 2. Troubleshooting History & Architecture Decisions

### Session: V1.9.2 Backmatter & IDE Stabilization

**Issue 1:** LaTeX Workshop failing to locate `climbingguide.sty` when compiling files inside subdirectories (`tests/` or `production/zones/`).
* **Root Cause:** Absolute workspace paths (`${workspaceFolder}`) fail when LaTeX Workshop spawns `latexmk` from active subdirectories.
* **Resolution:** Configured relative recursive search strings (`./src//:../src//:../../src//:`) in `.vscode/settings.json`, ensuring Kpathsea successfully resolves package dependencies regardless of document nesting depth.

**Issue 2:** Custom macros lacking intellisense autocomplete and tooltips in VS Code.
* **Root Cause:** LaTeX Workshop ignores raw `.cwl` files for local packages unless pre-compiled into internal schemas.
* **Resolution:** Registered core engine macros directly into `latex-workshop.intellisense.command.user` with snippet placeholders.
