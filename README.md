# LuaLaTeX Climbing Guidebook Engine (V1.5)

A decoupled, mathematically precise typesetting and data extraction engine designed for climbing guidebooks. 

This system enforces an absolute decoupling of presentation (LaTeX) from algorithmic logic and state memory (Lua). The `.tex` files are treated purely as declarative databases.

## I. System Architecture

The software is strictly divided into three orthogonal modules. Development is non-linear and continuous across all three domains:

1. **Core Engine (`src/`)**
   * The backend logic (`climbingguide.lua`) and frontend presentation layer (`cg-macros.sty`).
   * Handles string sanitization, grade parsing (Brazilian grading system), and automated generation of graphical elements (e.g., dynamic sector summary blocks).
   * Operates via a unidirectional data bridge: TeX acts as a declarative presentation layer, delegating all AST state memory and string transformations to the Lua backend.

2. **Test Suite (`tests/`)**
   * An isolated TDD (Test-Driven Development) environment. 
   * Used to independently validate Lua parsing logic, Strict Weak Ordering algorithms, and LaTeX graphic rendering without compiling the massive production book.

3. **Production Guide (`production/serra_do_cuo.tex`)**
   * The final compiled product, acting as a declarative database of climbing routes.

## II. Strict Architectural Constraints

* **Zero Manual Fine-Tuning:** The production `.tex` files must remain absolutely clean and declarative. No manual spacing (`\vspace`, `\hspace`), hardcoded formatting, or visual adjustments are permitted. Every layout variation or visual rule must be abstracted, automated, and handled internally by the `src/` modules.
* **Separation of Concerns:** The TeX engine is strictly a presentation layer. All algorithmic sorting, formatting exceptions, and data serialization are handled mathematically by the Lua backend. `expl3` string manipulations are strictly forbidden in the LaTeX layer.

## III. Build System & Export Pipeline

The project utilizes a `Makefile` to orchestrate multi-pass compilations, module resolution, and artifact routing. The `LUAINPUTS` and `TEXINPUTS` variables are natively exported to enforce proper Kpathsea module resolution.

### Core Commands

*   `make test`: Compiles the isolated test suites and validates layout algorithms.
*   `make production`: Compiles the final guidebook. Automatically purges stale `.cgstats` caches to prevent `expl3` deadlocks.
*   `make clean`: Purges auxiliary build artifacts (`.aux`, `.log`, `.pdf`) and all caches.

### Automated Data Export (Two-Pass Caching)

The engine maintains a running topological state during LaTeX compilation. At the termination of the document build (`\AtEndDocument`):
1. **Serialization:** The pure Lua JSON encoder automatically extracts the route database and serializes it to `export/database.json`.
2. **Global Statistics:** Lua aggregates route counts by difficulty and generates dynamic TikZ bar charts, exporting them to `*.cgstats`. On the subsequent `make` pass, LaTeX reads this cache to render the charts at the *top* of the document before the routes are actually parsed.

## IV. AI Agent Ingestion

This project is actively developed in collaboration with Large Language Models (LLMs). 

If you are an AI agent attempting to understand the macro API signatures, resolve compilation errors, or generate new sectors, **do not read this README.** 

Instead, immediately ingest and parse the strict XML schema located at:
`/doc/robot.md`

This file contains the deterministic API signatures (`\CGRoute`, `\CGZoneHeader`, etc.), environmental fragilities (WSL line endings, `expl3` bleed), and the explicit specifications for upcoming V1.6 features (Route Star Ratings, Overlay Captions).
