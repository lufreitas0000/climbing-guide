# LuaLaTeX Climbing Guidebook Engine: System Documentation & Architecture Manual

> **AI Ingestion Schema & Developer Guide (Version 1.5 & V1.6 Specs)**
> *Target System:* Hybrid LuaLaTeX (`expl3`, `luatex`) + POSIX CI/CD Pipeline.

---

## 1. Top-Level Directory Structure & Module Responsibilities

The project enforces an absolute decoupling between the presentation layer (\LaTeX) and the data/logic layer (Lua). Production source files remain purely declarative databases with zero manual spacing, hardcoded breaks, or visual overrides.

```text
climbing-guide-main/
├── Makefile                # Build orchestrator (compilation, test suite, and cache purging)
├── README.md               # User-facing project overview and build instructions
├── doc/                    # Human-readable documentation manual & robot.md (AI schema)
├── production/             # Final guidebook database ("Serra do Cuó")
│   ├── serra_do_cuo.tex    # Master document (frontmatter, zone ingestion, indexes)
│   ├── frontmatter.tex     # Introduction, history, and global statistics chart
│   ├── images/             # Covers (full-page banners) and topos (route line overlays)
│   └── zones/              # Individual zone files containing declarative sector blocks
├── scripts/                # CI/CD and auxiliary maintenance shell scripts
├── src/                    # Core engine codebase (.sty packages and .lua pure modules)
└── tests/                  # Test-Driven Development (TDD) environment for Lua logic

```

### 1.1 Source Code Matrix (`src/`)

* **`climbingguide.sty`**: Package loader and global configuration. Intercepts the LuaTeX input buffer to patch invisible `U+00A0` non-breaking spaces and sets paragraph tolerances.
* **`climbingguide.lua`**: The core AST orchestrator. Manages in-memory routing tables (`M.routes`), zone/sector contexts, and triggers JSON/TXT serialization.
* **`route_sorter.lua`**: Pure functional module enforcing Strict Weak Ordering via difficulty parsing and Portuguese accent normalization.
* **`sanitize_tex.lua`**: Lexical parser that validates brace depth ($\le 1$) and strips formatting macros prior to database insertion.
* **`export_json.lua` & `export_txt.lua**`: RFC 8259-compliant control character hex-serializer and fixed-delimiter schema writer.
* **`zone_stats.lua`**: In-memory tier aggregation module generating dynamic TikZ grade distribution bar charts.
* **`cg-colors.sty`, `cg-fonts.sty`, `cg-geometry.sty`, `cg-header.sty**`: Foundational design tokens, geometry rules, and two-sided header/footer management.
* **`cg-boxes.sty`, `cg-macros.sty`, `cg-lists.sty`, `cg-frontmatter.sty**`: Layout containers, public API presentation macros, multi-column index printers, and asymmetric cover page builders.
* **`cg-api.sty`**: State tracking pipeline, LaTeX3 counters, and auxiliary serialization hooks.

---

## 2. Environmental Fragilities & Technical Warnings

Future AI agents and developers must exercise strict caution regarding the following system-level bottlenecks:

1. **The `expl3` Catcode Bleed:** \LaTeX3 (`expl3`) enforces a strict parsing regime where standard whitespace is ignored. If `\ExplSyntaxOn` bleeds into the document via an improperly isolated cache read, spaces in route definitions (e.g., `3 IVsup`) are silently stripped before reaching Lua, triggering fatal parsing crashes.


2. **WSL Line Endings (`sed` vs. `perl`):** Windows Subsystem for Linux (WSL) environments inject hidden carriage returns (`\r\n`), breaking strict LF (`\n`) regex anchors in POSIX `sed`. Always use `perl -pi -e` for programmatic in-place file modifications.
3. **Two-Pass Cache Deadlocks:** Multi-column layouts and global statistics rely on an external `.cgstats` cache generated at `\AtEndDocument`. If a compiler crash occurs mid-build, the cache becomes poisoned. The `Makefile` explicitly purges these caches prior to building.
4. **Compiler Obfuscation:** Using `> /dev/null` completely destroys `stdout`, blinding the build pipeline to fatal LaTeX errors. The engine relies on `--interaction=batchmode` in the `Makefile` to suppress routine log noise while keeping compilation halts visible.



---

## 3. Public API Specification

```
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

```

---

## 4. Future Specifications: Version 1.6 Roadmap

```
<Feature name="Route Star Ratings">
    <Description>Ability to assign 1, 2, or 3 quality stars to a route directly via the \CGRoute macro.</Description>
    <Architecture>Due to LaTeX multicol limitations regarding dynamic left/right column float detection, stars will NOT be placed in the margins. The star payload (e.g., 1, 2, 3) will be integrated into the final optional [obs] argument of \CGRoute. The stars will be rendered as yellow TikZ vector shapes below the setter data, natively flowing with the column.</Architecture>
</Feature>

<Feature name="Overlay Captions for Full Page Images">
    <Description>Provide a mechanism to embed captions directly inside full-bleed, zero-margin images without breaking page geometry.</Description>
    <Architecture>A new macro \CGOverlayImage[caption]{path} will be introduced. It will wrap the image in a TikZ node, calculate the south-west anchor, and overlay a tcolorbox (with a 50% opacity gray background and white text) within the bounding box of the image itself.</Architecture>
</Feature>
```

# CLIMBING GUIDE ENGINE: AI INGESTION SCHEMA (V1.5 & V1.6 ROADMAP)
```
<ProjectStructure>
    <Directory path="src/" role="Core Engine">
        <Description>Decoupled backend logic and frontend presentation modules.</Description>
        <File name="climbingguide.sty">Package loader, global formatting tolerances, and input buffer U+00A0 sanitizer.</File>
        <File name="climbingguide.lua">AST state manager, route registration, and LaTeX-Lua bridge.</File>
        <File name="cg-api.sty">State tracking pipeline, LaTeX3 counters, and auxiliary triggers.</File>
        <File name="cg-boxes.sty">TikZ positioning, layout containers, and image sizing wrappers.</File>
        <File name="cg-colors.sty">Difficulty color matrix and extended accent palettes.</File>
        <File name="cg-date.lua">Pure Lua date formatting utility for localized timestamp generation.</File>
        <File name="cg-fonts.sty">Binary font loaders and explicit pt-sized semantic aliases.</File>
        <File name="cg-frontmatter.sty">Asymmetric layouts, cover builder, and native ToC styling.</File>
        <File name="cg-geometry.sty">Physical page dimensions, margins, and centralized lengths.</File>
        <File name="cg-header.sty">Two-sided running header/footer and page style management.</File>
        <File name="cg-lists.sty">Multi-column alphabetical and difficulty listing integration.</File>
        <File name="cg-macros.sty">Frontend visual presentation macros and box definitions.</File>
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

<VersionRoadmap target="1.6">
    <Goal name="Route Star Ratings">
        <Description>Add 1, 2, or 3 quality rating stars to routes via an extended optional parameter in \CGRoute.</Description>
        <Implementation>Rendered as yellow TikZ vector shapes below setter data alongside observation text. Scales relative to badge size (1-star large, 2/3-stars compact).</Implementation>
    </Goal>
    <Goal name="Overlay Captions for Full Page Images">
        <Description>Enable caption rendering inside full-bleed, zero-margin images.</Description>
        <Implementation>Introduce \CGOverlayImage[caption]{path} leveraging a TikZ node bounding box overlay with a 50% opacity gray background tcolorbox.</Implementation>
    </Goal>
    <Goal name="VS Code IntelliSense Snippets">
        <Description>Automated parser generating climbingguide.code-snippets JSON from robot.md signatures.</Description>
    </Goal>
</VersionRoadmap>
