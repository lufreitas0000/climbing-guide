local ZoneStats = {}
local Sanitizer = require("sanitize_tex")

function ZoneStats.render_zone_chart(target_zone, routes, get_val_func)
    local counts = {
        guide_cyan = 0,
        guide_green = 0,
        guide_yellow = 0,
        guide_orange = 0,
        guide_red = 0,
        guide_purple = 0,
        guide_gray = 0
    }

    for _, route in ipairs(routes) do
        if route.zone == Sanitizer.strip_tex_macros(target_zone) then
            local val = get_val_func(route.grade)
            if val == 999 then
                counts.guide_gray = counts.guide_gray + 1
            elseif val > 0 and val < 5 then
                counts.guide_cyan = counts.guide_cyan + 1
            elseif val >= 5 and val < 6 then
                counts.guide_green = counts.guide_green + 1
            elseif val >= 6 and val < 7 then
                counts.guide_yellow = counts.guide_yellow + 1
            elseif val >= 7 and val < 8 then
                counts.guide_orange = counts.guide_orange + 1
            elseif val >= 8 and val < 9 then
                counts.guide_red = counts.guide_red + 1
            elseif val >= 9 and val < 20 then
                counts.guide_purple = counts.guide_purple + 1
            else
                counts.guide_gray = counts.guide_gray + 1
            end
        end
    end

    local max_count = 1
    for _, count in pairs(counts) do
        if count > max_count then max_count = count end
    end

    local tiers = {"guide_cyan", "guide_green", "guide_yellow", "guide_orange", "guide_red", "guide_purple", "guide_gray"}
    
    tex.sprint("\\begin{tikzpicture}[baseline=0pt]")
    tex.sprint("\\draw[help lines, color=gray!30, dashed] (0,0) grid (7.0, 3.0);")
    
    local x = 0.5
    for _, tier in ipairs(tiers) do
        local h = (counts[tier] / max_count) * 2.5
        tex.sprint(string.format("\\fill[%s] (%.2f, 0) rectangle (%.2f, %.2f);", tier, x, x + 0.6, h))
        tex.sprint(string.format("\\node[above, font=\\tiny] at (%.2f, %.2f) {%d};", x + 0.3, h, counts[tier]))
        x = x + 0.9
    end
    
    tex.sprint("\\end{tikzpicture}")
end

return ZoneStats
