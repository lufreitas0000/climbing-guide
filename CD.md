# Architecture & Continuous Delivery (CD) Guidelines: Climbing Guidebook

## 1. Project Philosophy & Orthogonal Design
The software architecture strictly separates the presentation layer (LaTeX) from the business logic (Lua). The production environment must remain entirely declarative. Zero manual fine-tuning (`\vspace`, `\hspace`, hardcoded breaks) is permitted. 

### 1.1 Directory Topology
*   **`src/` (Core Engine):** Contains the isolated `.sty` and `.lua` modules defining the system's logic and graphical rules.
*   **`tests/` (Test Suite):** The TDD environment containing orthogonal tests for pure Lua math (`test_lua.lua`), fonts (`test_fonts.tex`), visual macros (`test_visual.tex`), and lists (`test_suite.tex`).
*   **`scripts/` (CI/CD Tools):** POSIX bash scripts for font verification and strict log parsing.
*   **`production/` (Production Guide):** The target declarative database (e.g., `serra_do_cuo.tex`).
*   **`export/` (Data Export):** Ignored by version control. Target directory for future JSON and plain-text catalog outputs.

## 2. Continuous Integration & TDD Pipeline
The `Makefile` orchestrates the validation process to prevent typographical or logical regressions.

*   **`make test-lua`:** Bypasses TeX. Executes the standalone Lua interpreter to validate mathematical grading assertions and strict formatting exceptions (`pcall`).
*   **`make test`:** The comprehensive pipeline. 
    1. Audits the system font cache (`scripts/check_fonts.sh`).
    2. Compiles `.tex` test files, redirecting `stdout` to `/dev/null` for minimal verbosity.
    3. Triggers `scripts/parse_logs.sh` to extract Fatal Errors, Warnings, and `Overfull \hbox` instances exceeding the `5.0pt` tolerance into `debug_test_<name>.log`. Halts compilation if this file is populated.

## 3. Core Engine Modules (`src/`)
*   **`cg-fonts.sty`:** Enforces strict binary font mapping (`fontspec`).
*   **`cg-colors.sty`:** Defines the hexadecimal grading scale matrix and subsector standard palettes.
*   **`cg-geometry.sty`:** Establishes page boundaries, column separation, and `\emergencystretch` tolerances.
*   **`cg-boxes.sty`:** Manages absolute graphical positioning using `TikZ` `[remember picture, overlay]`. Applies mathematical clipping paths to background images to prevent distortion.
*   **`cg-api.sty`:** The frontend macro interface (`\CGRoute`, `\CGSectorHeader`). It automates LaTeX3 counter increments and maps them to the visual output.
*   **`cg-lists.sty`:** Wraps the Lua array sorting functions into TeX multi-column lists.

## 4. Lua Backend Logic (`climbingguide.lua`)
The Lua engine processes the Brazilian multipitch grading system.

### 4.1 Strict Formatting Exceptions
Before parsing, the engine enforces strict grammar. It throws fatal errors for:
*   Missing spaces between general and free grades (e.g., `5VIIb`).
*   Unauthorized spaces before suffixes (e.g., `VII b`).
*   The `+` operator applied outside of artificial grades.

### 4.2 Grading Mathematics
*   **Averaging:** Extracts grades separated by `/` and returns the exact arithmetic mean (e.g., `6sup/7a` = `6.8`).
*   **Multipitch Maximum:** Strips general grades (`5°`) and parenthetical variants (`(A0/VIIb)`). Extracts the maximum free climbing grade from the remaining string.
*   **Artificial Logic:** Maps `A` grades to a base of 20 (e.g., `A4` = 24.0). Applies `+0.5` for the `+` operator (`A5+` = 25.5).

## 5. Future Implementation: JSON Directed Acyclic Graph (DAG)
To manage the scaling route database, the Lua engine will be expanded to export a `.json` graph representing the guidebook's topology.

*   **Structure:** Root (Crag: Serra do Cuó) $\rightarrow$ Nodes (Zones) $\rightarrow$ Sub-nodes (Sectors/Cliffs) $\rightarrow$ Leaves (Routes).
*   **Functionality:** Each node will store metadata (description, quantitative grade values). This JSON will act as a version control snapshot, allowing algorithmic diffing between guidebook editions to track bolted, altered, or deleted routes without parsing the LaTeX source.

## 6. Immediate Roadmap
1.  **Mini-guide Replica Test:** Construct an orthogonal test mimicking the absolute geometry, 2-column balancing, and visual hierarchy of the "Ibicoara Guide" reference PDF.
2.  **Typographical Refinement:** Fine-tune the sizes, kerning, and positioning of the `cg-fonts.sty` outputs against the visual replica.
