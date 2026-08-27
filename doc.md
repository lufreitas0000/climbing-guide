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
