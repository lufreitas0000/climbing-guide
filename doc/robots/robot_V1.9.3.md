# LuaLaTeX Climbing Guidebook Engine: System Documentation & Architecture Manual

> **AI Ingestion Schema & Developer Guide (Version 1.9.3 Specs)**
> *Target System:* Hybrid LuaLaTeX (`expl3`, `luatex`) + POSIX CI/CD Pipeline.

---

## 1. Top-Level Directory Structure & Module Responsibilities

The project enforces an absolute decoupling between the presentation layer (\LaTeX) and the data/logic layer (Lua). Version 1.9.3 introduces an idempotent Python generation layer to the pipeline.

<ProjectStructure>
    <Directory path="src/" role="Core Engine">
        <File name="qr_manager.lua">Parses URLs, extracts deterministic IDs, and serializes state to export/qrcodes_manifest.json.</File>
        <File name="cg-components.sty">LaTeX UI components, now containing decoupled \CGQRCode and \CGInjectZoneQR rendering macros.</File>
        <!-- ... existing modules ... -->
    </Directory>

    <Directory path="scripts/python/" role="External Asset Generation">
        <Description>Isolated Python environment (.venv) for generating dynamic assets.</Description>
        <File name="generate_qrcodes.py">Idempotent script using `segno` to read the Lua JSON manifest and generate high-resolution PNG QR codes.</File>
        <File name="requirements.txt">Strict dependencies (e.g., segno==1.6.1).</File>
    </Directory>

    <Directory path="production/production_assets/production_qrcodes/" role="Generated Assets">
        <Description>Git-ignored directory holding compiled .png matrices.</Description>
    </Directory>
</ProjectStructure>

<PublicAPI>
    <Macro name="\CGQRCode">
        <Signature>\CGQRCode[caption]{url}{additional_info}</Signature>
        <Arguments>
            <Arg type="optional" format="[]">caption: String. Typeset below the matrix.</Arg>
            <Arg type="mandatory" format="{}">url: String. The target hyperlink.</Arg>
            <Arg type="mandatory" format="{}">additional_info: String. Used to generate a deterministic filename (e.g., cuo_rupestre).</Arg>
        </Arguments>
        <Constraints>Renders relative/inline QR codes wrapped in a minipage. Falls back to a gray placeholder if the PNG is missing.</Constraints>
    </Macro>

    <Macro name="\CGAddQRCodeToZoneHeader">
        <Signature>\CGAddQRCodeToZoneHeader{url}{additional_info}</Signature>
        <Arguments>
            <Arg type="mandatory" format="{}">url: String.</Arg>
            <Arg type="mandatory" format="{}">additional_info: String.</Arg>
        </Arguments>
        <Constraints>Does NOT render immediately. Injects state into global expl3 token lists (\g_guide_pending_qr_url_tl). Must be called exactly before \CGZoneHeader.</Constraints>
    </Macro>
</PublicAPI>

<VersionSpec version="1.9.3">
    <Description>QR Code Infrastructure, Python Orchestration, and IDE Synchronization.</Description>
    
    <Enhancement name="Automated QR Pipeline">
        <Description>Implemented a 2-pass compilation pipeline. Pass 1 (LuaLaTeX) parses URLs and dumps a JSON manifest. The Makefile orchestrates a Python generator (using `segno`) to build missing PNGs. Pass 2 (LuaLaTeX) resolves the generated assets onto the page.</Description>
    </Enhancement>
</VersionSpec>

## 2. Troubleshooting History & Architecture Decisions

### Session: V1.9.3 QR Code Rendering & Build Orchestration

**Issue 1: Horizontal Slicing in QR Codes (Vector Anti-Aliasing Bug)**
* **Attempt (PDF Vector):** Initially used `.pdf` for infinite scalability. When overlaid on colored headers in VS Code's PDF.js viewer, the transparency flattener sliced the vector paths, causing sub-pixel horizontal white lines.
* **Attempt (Internal Opacity):** Instructed Python to set `light='#FFFFFF'` to force internal opacity. The PDF viewer still attempted to stitch abutting vector rectangles, failing to eliminate the artifact entirely.
* **Resolution (High-Res PNG):** Transitioned to rasterized PNGs (`scale=20`, ~600 DPI) using `segno`. A raster grid is mathematically immune to PDF.js floating-point stitching gaps.

**Issue 2: VS Code LaTeX Workshop Build Hijacking**
* **Root Cause:** The LaTeX Workshop extension rigidly defaults to `latexmk` for compilation, bypassing our custom Lua -> Python -> LuaLaTeX multi-pass `Makefile` orchestration. This caused "missing tool" crashes.
* **Resolution:** Completely overrode the `.vscode/settings.json` "tools" and "recipes" arrays, directly mapping `make test-qr` and `make production` to the UI buttons. Preserved `latex-workshop.intellisense.command.user` to maintain custom macro autocomplete snippets and environment variables.

**Issue 3: Ghost Nodes Corrupting TikZ Zone Headers**
* **Root Cause:** In `cg-components.sty`, `\tl_if_empty:NTF` evaluated an empty QR token list as `{ }` (an empty group). Injecting this ghost group immediately after the primary `\CGZoneHeader` overlay broke the vertical spacing engine, causing the red banner and text to vanish entirely.
* **Resolution:** Replaced with `\tl_if_empty:NF`, which outputs absolute zero tokens when false. Furthermore, completely encapsulated the QR injection (`\CGInjectZoneQR`) in a separate, isolated `\begin{tikzpicture}[overlay]` block to ensure rendering independence.

**Issue 4: Hyperref URL Color Bleeding**
* **Root Cause:** `hyperref` globally styled links as red at 60% opacity. Because the QR code was wrapped in `\href`, it inherited this styling, rendering as faded red instead of absolute black.
* **Resolution:** Scoped the QR rendering inside `\begingroup \hypersetup{urlcolor=black} \textcolor{black}{...} \endgroup` to strictly enforce 100% opacity black without altering document-wide hyperlink variables.
