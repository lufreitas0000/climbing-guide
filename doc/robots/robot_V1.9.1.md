# Architecture Resolution: V1.9.1 Memory Layer Synchronization

## Issue: State Desynchronization and Catcode Regression
During the testing of V1.9, generating new zones via `\CGZoneHeader` failed catastrophically, throwing the `! Undefined control sequence. \cs_if_exist:cTF` error inside the test logs, while skipping empty zones entirely.

## Mechanical Breakdown
1. **The Zone Missing Bug:** The Lua caching function aggregated routes. If a zone contained 0 routes, it was never added to the `.cgstats` cache, causing the presentation layer to render an infinite fallback loop.
2. **The Catcode Mismatch:** To bridge the cached graphs, Lua sprinted the `\cs_if_exist:cTF` command back to LaTeX. Because this sprint occurred inside the document body (which runs on standard Catcodes, not `\ExplSyntaxOn`), the underscore `_` was evaluated as a math subscript, crashing the tokenizer.

## Solutions Enforced
* **`\CGRenderZoneStatsInternal` Bridge:** The `expl3` command execution is decoupled into `cg-engine.sty`. Lua now exclusively prints the safe parameter wrapper, removing all raw syntax from the memory buffer.
* **Manual Star Bypassing:** The `\CGRoute` macro now supports an optional `*` flag. While the standard algorithm safely compresses route names up to 165% of the bounding limit, executing `\CGRoute*{Name}` manually forces the layout engine to split the title into multiple lines without shrinking.
