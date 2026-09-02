# LuaLaTeX Climbing Guidebook Engine: System Documentation & Architecture Manual

> **AI Ingestion Schema & Developer Guide (Version 1.6 Specs)**
> *Target System:* Hybrid LuaLaTeX (`expl3`, `luatex`) + POSIX CI/CD Pipeline.

---

## 1. Top-Level Directory Structure & Module Responsibilities

The project enforces an absolute decoupling between the presentation layer (\LaTeX) and the data/logic layer (Lua). Production source files remain purely declarative databases with zero manual spacing, hardcoded breaks, or visual overrides.

<ProjectStructure>
    <Directory path="src/" role="Core Engine">
        <Description>Decoupled backend logic and frontend presentation modules.</Description>
        <File name="climbingguide.sty">Package loader, global formatting tolerances, and input buffer U+00A0 sanitizer.</File>
        <File name="climbingguide.lua">AST state manager, route registration, and LaTeX-Lua bridge.</File>
        <File name="cg-api.sty">State tracking pipeline, LaTeX3 counters, and auxiliary triggers.</File>
        <File name="cg-boxes.sty">TikZ positioning, layout containers, overlay images, and image sizing wrappers.</File>
        <File name="cg-colors.sty">Difficulty color matrix and extended accent palettes.</File>
        <File name="cg-date.lua">Pure Lua date formatting utility for localized timestamp generation.</File>
        <File name="cg-fonts.sty">Binary font loaders and explicit pt-sized semantic aliases.</File>
        <File name="cg-frontmatter.sty">Asymmetric layouts, cover builder, and native ToC styling.</File>
        <File name="cg-geometry.sty">Physical page dimensions, margins, and centralized lengths.</File>
        <File name="cg-header.sty">Two-sided running header/footer and page style management.</File>
        <File name="cg-lists.sty">Multi-column alphabetical and difficulty listing integration, including star ratings.</File>
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

<VersionSpec version="1.6">
    <Description>Finalized V1.6 API constraints and feature implementations.</Description>
    
    <Macro name="\CGstar">
        <Signature>\CGstar{n}</Signature>
        <Arguments>
            <Arg type="mandatory" format="{}">n: Integer (1, 2, or 3). The number of stars to render.</Arg>
        </Arguments>
        <Constraints>Must be used at the very beginning of the optional [obs] argument within \CGRoute. The TeX engine intercepts this via expl3 regex to render a zero-width right-aligned TikZ vector in the left margin. The Lua engine concurrently parses this token to populate the 'stars' attribute for list indexing and JSON/TXT exports.</Constraints>
    </Macro>

    <Macro name="\CGOverlayImage">
        <Signature>\CGOverlayImage[caption]{path}</Signature>
        <Arguments>
            <Arg type="optional" format="[]">caption: String. Text to be rendered in the semi-transparent box.</Arg>
            <Arg type="mandatory" format="{}">path: String. Path to the image file.</Arg>
        </Arguments>
        <Constraints>Automatically triggers \clearpage. Generates a full A5-bleed image using \clip against the absolute page geometry. The caption is anchored to the south-west using \CGMarginWidth coordinates inside a 50% opacity background box. Automatically increments the global figure counter and prepends "Figura X:" to the caption text.</Constraints>
    </Macro>
    
    <Enhancement name="Zone Stats Math Alignment">
        <Description>Roman numerals (IV and IX) in the \CGZoneStats TikZ chart are mathematically centered by prepending the \leq and \geq operators inside zero-width right-aligned TeX boxes (\makebox[0pt][r]{...}), preventing visual skewing in the generated bar graphs.</Description>
    </Enhancement>
</VersionSpec>

## 2. Troubleshooting History & Architecture Decisions

### Session: Zone Header & Overlay Image Layout Resolution

**Issue:** \CGZoneHeader failed to render graphics/text, and \CGOverlayImage displayed high-resolution raw images at massive scale (hyper-zoomed) while breaking page flows.

**Attempt 1: Layout Flush & Box Injection**
* Action: Injected \clearpage and \mbox{} to force horizontal mode and synchronize absolute page coordinates before TikZ evaluation.
* Failure: The scaling issue persisted. \includegraphics[min width=\paperwidth, min height=\paperheight] fails to downscale high-resolution images because their raw dimensions already exceed the minimum constraints.

**Attempt 2: TikZFill Integration**
* Action: Attempted to replace manual clipping with \fill [fill image={...}] using the tikzfill.image library to emulate CSS object-fit: cover.
* Failure: Compilation halted with pgfkeys error: "I do not know the key '/tikz/fill image'". The library was loaded implicitly via tcolorbox but not explicitly declared in \usetikzlibrary, causing a namespace scope failure.

**Attempt 3: tcolorbox Watermarks & ExplSyntaxOn Conflict**
* Action: Attempted to use native tcolorbox skins with watermark zoom=1.0 and explicitly imported the fill.image library.
* Failure: Compilation halted with Error 1. The cg-boxes.sty file was wrapped in \ExplSyntaxOn. In LaTeX3 syntax, standard spaces are ignored, forcing the use of ~ (e.g., watermark~zoom=1.0). The pgfkeys parser interprets keys literally and rejected the tilde characters as invalid syntax, silently discarding the formatting instructions and outputting massive unscaled images. Furthermore, the \DrawSummaryBlock macro was accidentally overwritten during testing.

**Final Resolution: Pure LaTeX2e & Adjustbox Mathematical Cropping**
* Action: Completely removed the \ExplSyntaxOn scope from cg-boxes.sty, substituting expl3 condition checks with native LaTeX2e \ifcsname. This resolved all pgfkeys space tokenization conflicts.
* Action: Restored the \DrawSummaryBlock macro.
* Action: Abandoned tikzfill and tcolorbox watermarks entirely. Implemented deterministic CSS object-fit: cover logic using adjustbox bounded by a strict tikzpicture clip path.
* Implementation: 
  \clip (current page.north west) rectangle (current page.south east);
  \node[anchor=center] at (current page.center) {
      \adjustbox{width=\paperwidth, min height=\paperheight}{\includegraphics{...}}
  };
* Result: The image is mathematically forced to match the paper width first. If the resulting scaled height is less than the paper height, the min height parameter triggers further scaling. The outer \clip trims the excess overflow, rendering perfectly centered, distortion-free full-bleed graphics regardless of the source image's native resolution.
