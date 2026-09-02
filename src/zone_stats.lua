local ZoneStats = {}
local Sanitizer = require("sanitize_tex")

function ZoneStats.get_chart_string(target_zone, routes, get_val_func)
    local counts = {
        guide_cyan = 0, guide_green = 0, guide_yellow = 0,
        guide_orange = 0, guide_red = 0, guide_purple = 0, guide_gray = 0
    }

    for _, route in ipairs(routes) do
        if target_zone == "Global" or route.zone == Sanitizer.strip_tex_macros(target_zone) then
            local val = get_val_func(route.grade)
            if val == 999 then counts.guide_gray = counts.guide_gray + 1
            elseif val > 0 and val < 5 then counts.guide_cyan = counts.guide_cyan + 1
            elseif val >= 5 and val < 6 then counts.guide_green = counts.guide_green + 1
            elseif val >= 6 and val < 7 then counts.guide_yellow = counts.guide_yellow + 1
            elseif val >= 7 and val < 8 then counts.guide_orange = counts.guide_orange + 1
            elseif val >= 8 and val < 9 then counts.guide_red = counts.guide_red + 1
            elseif val >= 9 and val < 20 then counts.guide_purple = counts.guide_purple + 1
            else counts.guide_gray = counts.guide_gray + 1
            end
        end
    end

    local tiers = {"guide_cyan", "guide_green", "guide_yellow", "guide_orange", "guide_red", "guide_purple", "guide_gray"}
    local labels = {
        guide_cyan = "\\makebox[0pt][r]{$\\leq$~}IV", 
        guide_green = "V", guide_yellow = "VI", guide_orange = "VII", guide_red = "VIII", 
        guide_purple = "\\makebox[0pt][r]{$\\geq$~}IX", guide_gray = "?"
    }
    
    local out = "\\begin{tcolorbox}[colback=bg_beige, colframe=bg_beige, boxrule=0pt, arc=4pt, left=4mm, right=4mm, top=4mm, bottom=4mm]\n"
    out = out .. "\\begin{center}\n\\begin{tikzpicture}[baseline=0pt]\n"
    out = out .. "\\draw[help lines, color=gray!40, dashed] (0,0) -- (7.0, 0);\n"
    
    local bar_width = 0.6
    local bar_spacing = 0.9
    local start_x = 0.5
    local unit_scale = 0.08
    local x = start_x

    for _, tier in ipairs(tiers) do
        local count = counts[tier]
        local h = count * unit_scale
        if count == 0 then h = 0.04 end 
        
        out = out .. string.format("\\fill[%s] (%.2f, 0) rectangle (%.2f, %.2f);\n", tier, x, x + bar_width, h)
        
        if count > 0 then
            out = out .. string.format("\\node[above, font=\\tiny] at (%.2f, %.2f) {%d};\n", x + (bar_width / 2), h, count)
        else
            out = out .. string.format("\\node[above, font=\\tiny, text=gray] at (%.2f, %.2f) {0};\n", x + (bar_width / 2), h)
        end
        out = out .. string.format("\\node[below, font=\\tiny\\sffamily] at (%.2f, -0.05) {%s};\n", x + (bar_width / 2), labels[tier])
        x = x + bar_spacing
    end
    
    out = out .. "\\end{tikzpicture}\n\\end{center}\n\\end{tcolorbox}"
    return out
end

function ZoneStats.render_zone_chart(target_zone, routes, get_val_func)
    tex.sprint(ZoneStats.get_chart_string(target_zone, routes, get_val_func))
end

return ZoneStats
