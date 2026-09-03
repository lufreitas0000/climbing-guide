# LuaLaTeX Climbing Guidebook Engine: System Documentation & Architecture Manual

> **AI Ingestion Schema & Developer Guide (Version 1.9 Specs)**
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
        <File name="cg-components.sty">Consolidated Domain (Pure LaTeX2e): Frontend visual macros, TikZ positioning, layout containers, image sizing wrappers, and multi-column lists.</File>
        <File name="cg-frontmatter.sty">Domain: Asymmetric layouts, cover builder, and native ToC styling.</File>
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
        <Directory path="zones/">Individual .tex files (e.g., paraiso.tex, zona_baixa.tex) containing \CGSectorRoutes environments.</Directory>
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
            <Arg type="mandatory" format="{}">grade: String. Adheres to Brazilian grade logic (e.g., 7a, 4sup, 3 IVsup, Proj). Subject to Strict Weak Ordering.</Arg>
            <Arg type="mandatory" format="{}">length: String. Height (e.g., 15m).</Arg>
            <Arg type="mandatory" format="{}">gear: String. Protection required (e.g., 3+2, Móvel).</Arg>
            <Arg type="mandatory" format="{}">setter: String. First ascencionist or setter.</Arg>
            <Arg type="optional" format="[]">obs: String. Beta, warnings, or observation text. Prints below the route block.</Arg>
        </Arguments>
        <Constraints>Must be placed strictly inside the \begin{CGSectorRoutes} environment.</Constraints>
    </Macro>

    <Macro name="\CGFullWidthImage">
        <Signature>\CGFullWidthImage[caption]{path}</Signature>
        <Arguments>
            <Arg type="optional" format="[]">caption: String. Formatted in italics below the image.</Arg>
            <Arg type="mandatory" format="{}">path: String. Image file path.</Arg>
        </Arguments>
        <Constraints>Bypasses column geometry to span the entire \textwidth. Place STRICTLY OUTSIDE CGSectorRoutes.</Constraints>
    </Macro>

    <Macro name="\CGHalfWidthImage">
        <Signature>\CGHalfWidthImage[caption]{path}</Signature>
        <Arguments>
            <Arg type="optional" format="[]">caption: String. Formatted in italics below the image.</Arg>
            <Arg type="mandatory" format="{}">path: String. Image file path.</Arg>
        </Arguments>
        <Constraints>Confines image to 48% linewidth. Left-aligned. Places a par break after execution. Place OUTSIDE CGSectorRoutes.</Constraints>
    </Macro>

    <Macro name="\CGRouteImageRight">
        <Signature>\CGRouteImageRight[caption]{path}{routes_env}</Signature>
        <Arguments>
            <Arg type="optional" format="[]">caption: String.</Arg>
            <Arg type="mandatory" format="{}">path: String. Image file path.</Arg>
            <Arg type="mandatory" format="{}">routes_env: LaTeX block. Usually a \begin{CGSectorRoutes}[1] ... \end{CGSectorRoutes} block.</Arg>
        </Arguments>
        <Constraints>Anchors the routes_env to the top-left (48% width) and the image to the top-right (48% width) using aligned minipages.</Constraints>
    </Macro>

    <Macro name="\CGZoneStats">
        <Signature>\CGZoneStats{zone_name}</Signature>
        <Arguments>
            <Arg type="mandatory" format="{}">zone_name: String. To render all crag routes, pass "Global".</Arg>
        </Arguments>
        <Constraints>Reads the pre-compiled TikZ string from the .cgstats cache to bypass pass-1 evaluation errors.</Constraints>
    </Macro>
</PublicAPI>

<VersionSpec version="1.9">
    <Description>Architectural consolidation and layout engine stabilization.</Description>
    
    <Enhancement name="Consolidated Modules">
        <Description>The src/ directory was refactored to consolidate 8 fragmented files into 3 domain-specific modules: cg-theme.sty (design tokens), cg-components.sty (layout & frontend macros, strictly LaTeX2e), and cg-engine.sty (expl3 state management). This minimizes dependencies and strongly enforces separation of concerns between syntax layers.</Description>
    </Enhancement>

    <Enhancement name="Image Downscaling Invariant">
        <Description>Resolved an algorithmic discrepancy where massive high-resolution images (e.g., 3035x4047pt) were failing to downscale, causing the TikZ \clip path to isolate a hyper-zoomed fragment. The layout engine now strictly utilizes \adjustbox{width=#1, min height=#2}, forcing the width downscaling before evaluating the minimum bounding height.</Description>
    </Enhancement>

    <Enhancement name="Native hbox Fallbacks">
        <Description>Replaced the tcolorbox dependency for missing image fallbacks with a native \fcolorbox wrapped around a \minipage. This resolves a severe 'nested tikzpicture' bug that caused silent rendering failures when an image was missing inside a \CGZoneHeader or \CGOverlayImage, as tcolorbox uses TikZ under the hood.</Description>
    </Enhancement>

    <Enhancement name="Symmetric Bounding Box Constraints">
        <Description>Resolved a bug in \CGZoneHeader where providing no optional label caused the title text to disappear or overflow. The text node now utilizes a strict, symmetric \begin{minipage}{0.75\textwidth} wrapper regardless of arguments, natively inheriting \color{white} and enforcing proper bounding box constraints and text wrapping for long zone names.</Description>
    </Enhancement>
</VersionSpec>

## 2. Troubleshooting History & Architecture Decisions

### Session: V1.8 Architecture Fix - Catcode Mismatches and expl3 Space Stripping

**Issue 1:** Fatal Error `! Undefined control sequence. \__hook enddocument ...eCols \ExplSyntaxOn \guide _save_sector_summary: \Exp...`.
* **Root Cause:** A catcode execution timeline mismatch. We placed `\ExplSyntaxOn` inside the `\AtEndDocument` kernel hook. LaTeX tokenizes and locks the catcodes of a hook payload when it is *declared*, not when it executes. Because the document was in standard LaTeX2e mode at declaration time, the underscore `_` was parsed as a math subscript.
* **Resolution:** Created a secure LaTeX2e wrapper command scoped inside an active `\ExplSyntaxOn` block. The wrapper securely inherits the correct catcodes and is cleanly executed by the hook.

**Issue 2:** `pgfkeys` parser failure and layout distortion in image rendering.
* **Root Cause:** `cg-components.sty` contents were entirely wrapped in `\ExplSyntaxOn`. LaTeX3 strips all normal spaces, forcing the use of `~` for spacing. Key-value parsers like `pgfkeys` (used by TikZ and tcolorbox) rely heavily on exact string matching including spaces (e.g., `min width`). The injected tildes were rejected by `pgfkeys`.
* **Resolution:** Decoupled data from presentation. All TikZ drawing macros are now explicitly defined in `\ExplSyntaxOff` blocks. `\ExplSyntaxOn` is reserved solely for parsing state (in `cg-engine.sty`).

### Session: V1.9 Resolution of the Zone Header & Image Missing Bugs

**Issue:** \CGZoneHeader text was invisible in production, and overlay images were massively zoomed in.
* **Resolution:** Executed the V1.9 architectural consolidation described in the `<VersionSpec version="1.9">` block above, swapping to native `width=#1` downscaling, `\fcolorbox` fallbacks, and a strictly symmetric `minipage` text wrapper inside the overlay nodes.
