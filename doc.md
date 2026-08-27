# Architecture & TeX-Lua Bridge Documentation

## 1. Top-Level Philosophy
This guidebook engine enforces a strict decoupling of presentation (LaTeX) from logic and state (Lua). The `.tex` files are pure declarative databases. All algorithmic sorting, formatting exceptions, and data serialization are handled mathematically by the Lua backend.

## 2. In-Compilation State Memory (AST Alternative)
Instead of utilizing an external parser to generate the JSON export, the system uses the LuaTeX engine's active runtime memory.
As the TeX compiler sequentially reads `serra_do_cuo.tex`:
1. `\CGZoneHeader` fires `\directlua{cg.set_zone(...)}`, updating `M.current_zone`.
2. `\CGSectorHeader` fires `\directlua{cg.set_sector(...)}`, updating `M.current_sector`.
3. `\CGRoute` fires `\directlua{cg.register_route(...)}`, inserting the complete topological object (inheriting the active zone and sector) into the `M.routes` array.

## 3. Pure Lua JSON Encoder
To maintain zero external dependencies (no `luarocks` or `dkjson`), the `climbingguide.lua` module implements a deterministic string builder (`escape_json`). It sanitizes control characters (newlines, quotes, carriage returns) and iterates over the `M.routes` array to serialize a strictly formatted, flat JSON array. This is triggered automatically at the termination of the document compilation via the `\AtEndDocument` LaTeX hook.

## 4. TeX `expl3` Bridge Macros
Because Lua outputs strings back into the TeX input stream using standard category codes, injecting `expl3` syntax (`_`, `:`) from Lua causes undefined control sequence crashes. To bridge this boundary, Lua exclusively outputs standard LaTeX2e macros (e.g., `\CGEvalGrade`). These bridge macros reside safely within the `\ExplSyntaxOn` blocks in `cg-api.sty` and parse the standard strings into the necessary `expl3` variable assignments.

## 5. Architectural Compliance and System Diagnostics

### 5.1 State Management and Execution Lifecycle
The engine operates on a hybrid execution model to satisfy spatial layout constraints and global data aggregation. Route data is synchronously processed to render the physical guidebook structure sequentially. Concurrently, the Lua backend acts as a stateful database, aggregating route metadata into a global memory table. Global operations—such as alphabetical sorting, difficulty ranking, and JSON serialization—are strictly deferred until the entire declarative syntax tree is parsed, executing via the `\AtEndDocument` hook.

### 5.2 Lexical Analysis and String Sanitization
Data forwarded from the TeX layer via `\luaescapestring{\unexpanded{#x}}` bypasses compilation crashes but retains raw TeX control sequences (e.g., `\textbf{}`, `\color{}`). To prevent serialization corruption in downstream integrations, a lexical sanitization pipeline is required within `M.register_route`. This pipeline utilizes pattern-matching algorithms to strip macro syntax, extracting exclusively the pure UTF-8 text payload prior to database insertion.

### 5.3 JSON Serialization Compliance
To maintain zero external dependencies while satisfying strict parsing standards, the pure Lua JSON encoder must be rigorously RFC 8259 compliant. The internal `escape_json` function processes standard delimiters (double quotes, backslashes, newlines) and is designed to dynamically capture and hex-escape all unescaped Unicode control characters (U+0000 through U+001F), guaranteeing external parsing stability.

### 5.4 Grading System Poset Mapping (Strict Weak Ordering)
The Brazilian grading system utilizes non-linear, alphanumeric modifiers (e.g., 5sup, 6a/b, 7c+). The Lua backend addresses this by implementing a deterministic parser (`M.get_val`) that evaluates lexical tokens and applies a bijective mapping function to convert suffix strings into fractional modifiers (e.g., `a` = 0.1, `sup` = 0.5). This maps the totally ordered set of physical grades to a subset of the rational numbers, establishing the Strict Weak Ordering required for accurate algorithmic sorting.

### 5.5 Compiler Security and I/O Permissions
The LuaTeX engine adheres to local TeX Live security configurations (governed by the `openout_any` parameter), which restrict arbitrary write operations. To comply with these I/O permissions without modifying local `texmf.cnf` security policies, the continuous integration pipeline (`Makefile`) explicitly orchestrates the directory topology, validating and scaffolding the local `export/` target path prior to runtime execution.
