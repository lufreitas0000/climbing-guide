CLIMBING GUIDE ENGINE: AI INGESTION SCHEMA (V1.5)<Directory path="production/" role="User Database">
    <Description>The declarative database. Contains only data and layout flow macros, zero logic.</Description>
    <File name="serra_do_cuo.tex">The master document. Sets global headers and ingests zone files.</File>
    <File name="frontmatter.tex">Introduction, history, and the \CGZoneStats{Global} aggregated chart.</File>
    <Directory path="zones/">Individual .tex files (e.g., paraiso.tex, zona_baixa.tex) containing \CGSectorRoutes environments.</Directory>
    <Directory path="images/">Contains 'covers' (full page banners) and 'topos' (route line images).</Directory>
</Directory>

<Directory path="scripts/" role="CI/CD Pipeline">
    <File name="clean_nbsp.sh">Perl script to strip invisible U+00A0 clipboard spaces that break column balancing.</File>
    <File name="parse_logs.sh">Scrapes lualatex .log files to print fatal errors to stdout.</File>
</Directory>

<File name="Makefile" role="Build Orchestrator">
    <Description>Manages the multi-pass compilation. Crucially, the "production" target automatically purges the *.cgstats cache files before running to prevent expl3 cache deadlocks.</Description>
</File>
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
        <Arg type="mandatory" format="{}">grade: String. Must adhere to Brazilian grade logic (e.g., 7a, 4sup, 3 IVsup, Proj). Strict Weak Ordering mapping applies.</Arg>
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
    <Constraints>Must be placed STRICTLY OUTSIDE the CGSectorRoutes environment to avoid breaking multicol column balancing.</Constraints>
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
<Feature name="Route Star Ratings">
    <Description>Ability to assign 1, 2, or 3 quality stars to a route directly via the \CGRoute macro.</Description>
    <Architecture>Due to LaTeX multicol limitations regarding dynamic left/right column float detection, stars will NOT be placed in the margins. The star payload (e.g., 1, 2, 3) will be integrated into the final optional [obs] argument of \CGRoute (or a newly appended optional argument). The stars will be rendered as yellow TikZ vector shapes below the setter data, natively flowing with the column.</Architecture>
</Feature>

<Feature name="Overlay Captions for Full Page Images">
    <Description>Provide a mechanism to embed captions directly inside full-bleed, zero-margin images without breaking page geometry.</Description>
    <Architecture>A new macro \CGOverlayImage[caption]{path} will be introduced. It will wrap the image in a TikZ node, calculate the south-west anchor, and overlay a tcolorbox (with a 50% opacity gray background and white text) within the bounding box of the image itself.</Architecture>
</Feature>
