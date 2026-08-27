# LuaLaTeX Climbing Guidebook Engine

A decoupled, mathematically precise typesetting and data extraction engine for climbing guidebooks. 

## I. System Architecture

The software is strictly divided into three orthogonal modules. Development is non-linear and continuous across all three domains:

1. **Core Engine (`climbingguide.sty` & `climbingguide.lua`)**
   * The backend logic and frontend presentation layer.
   * Handles string sanitization, grade parsing (Brazilian grading system), and automated generation of graphical elements (e.g., dynamic sector summary blocks).
   * Operates via a unidirectional data bridge: TeX acts as a declarative presentation layer, delegating all AST state memory and string transformations to the Lua backend.

2. **Test Suite (`test_suite.tex` & `test_miniguide.tex`)**
   * An isolated TDD (Test-Driven Development) environment. 
   * Used to independently validate Lua parsing logic, edge cases, sorting algorithms, and LaTeX graphic rendering without compiling the entire production book.
   * Utilizes the `mwe` package for generic image mocking to ensure zero external file dependencies during structural tests.

3. **Production Guide (`serra_do_cuo.tex`)**
   * The final compiled product specifically for the "Serra do Cuó" crag, acting as a declarative database of climbing routes.

## II. Strict Architectural Constraints

* **Zero Manual Fine-Tuning:** The production `.tex` files must remain absolutely clean and declarative. No manual spacing (`\vspace`, `\hspace`), hardcoded formatting, or visual adjustments are permitted. Every layout variation or visual rule must be abstracted, automated, and handled internally by the `climbingguide.sty` module.
* **Separation of Concerns:** The TeX engine is strictly a presentation layer. All algorithmic sorting, formatting exceptions, and data serialization are handled mathematically by the Lua backend. `expl3` string manipulations are strictly forbidden in the LaTeX layer.

## III. Build System & Export Pipeline

The project utilizes a `Makefile` to orchestrate compilation, module resolution, and artifact routing. The `LUAINPUTS` and `TEXINPUTS` variables are natively exported to enforce proper Kpathsea module resolution.

### Core Commands

*   `make test-miniguide`: Compiles the isolated minimum working example and validates layout algorithms.
*   `make production`: Compiles the final `serra_do_cuo.tex` guidebook.
*   `make clean`: Purges auxiliary build artifacts (`.aux`, `.log`, `.pdf`) from the output directories.

### Automated Data Export

The engine maintains a running topological state during LaTeX compilation. At the termination of the document build (`\AtEndDocument`), the pure Lua JSON encoder automatically extracts the route database and serializes it to `export/database.json`. This flat JSON array includes the hierarchical parent zone and sector for every registered route, ensuring zero dependencies on external Lua libraries.
