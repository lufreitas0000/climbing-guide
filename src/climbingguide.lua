local M = {}
M.routes = {}

local romans = {"xii", "viii", "vii", "iii", "xi", "ix", "vi", "iv", "ii", "x", "v", "i"}
local roman_map = { xii=12, xi=11, x=10, ix=9, viii=8, vii=7, vi=6, v=5, iv=4, iii=3, ii=2, i=1 }

local function get_suffix(suf)
    if suf == "a" then return 0.1 elseif suf == "b" then return 0.4 elseif suf == "c" then return 0.6 elseif suf == "sup" then return 0.5 end
    return 0.0
end

local function parse_grade(token)
    for _, roman in ipairs(romans) do
        if string.sub(token, 1, #roman) == roman then
            local suf = string.sub(token, #roman + 1)
            return roman_map[roman] + get_suffix(suf)
        end
    end
    local num, suf = string.match(token, "^(%d+)(.*)$")
    if num then return tonumber(num) + get_suffix(suf) end
    return 0
end

function M.get_val(g)
    local g_low = string.lower(g)
    if string.match(g_low, "proj") then return 999 end

    g_low = string.gsub(g_low, "%d+[°º]", " ")
    local outside = string.gsub(g_low, "%(.-%)", " ")
    
    local max_val = 0
    for token in string.gmatch(outside, "[a-z0-9]+") do
        if not string.match(token, "^[eda]%d+") then
            local val = parse_grade(token)
            if val > max_val then max_val = val end
        end
    end
    return max_val
end

function M.eval_tex(g)
    local max_val = M.get_val(g)
    if max_val == 999 then 
        tex.sprint("\\tl_set:Nn \\l_guide_current_grade_color_tl {guide_gray} \\int_gincr:N \\g_guide_gray_int")
        return
    end

    local is_top = (math.abs((max_val % 1) - 0.5) < 0.01 or math.abs((max_val % 1) - 0.6) < 0.01)
    local color = "guide_gray"
    local base = "gray"

    if max_val > 0 and max_val < 5 then color, base = "guide_cyan", "cyan"
    elseif max_val >= 5 and max_val < 6 then color, base = "guide_green", "green"
    elseif max_val >= 6 and max_val < 7 then color, base = "guide_yellow", "yellow"
    elseif max_val >= 7 and max_val < 8 then color, base = "guide_orange", "orange"
    elseif max_val >= 8 and max_val < 9 then color, base = "guide_red", "red"
    elseif max_val >= 9 then color, base = "guide_purple", "purple"
    end

    if base ~= "gray" and not is_top then color = color .. "!60!black" end
    local top_str = is_top and "_top" or "_bot"

    tex.sprint("\\tl_set:Nn \\l_guide_current_grade_color_tl {" .. color .. "} ")
    if base ~= "gray" then tex.sprint("\\int_gincr:N \\g_guide_" .. base .. top_str .. "_int ") end
end

-- Export functions for listing
function M.print_alpha()
    local sorted = {}
    for _, v in ipairs(M.routes) do table.insert(sorted, v) end
    table.sort(sorted, function(a, b) return string.lower(a.name) < string.lower(b.name) end)
    tex.sprint("\\begin{itemize}[label={}, leftmargin=0pt, itemsep=4pt]")
    for _, v in ipairs(sorted) do
        tex.sprint("\\item {\\CGBaseFont\\bfseries " .. v.name .. "} \\dotfill {\\small " .. v.sector .. "} \\dotfill {\\CGBaseFont\\slshape " .. v.grade .. "}~({\\small " .. v.id .. "})")
    end
    tex.sprint("\\end{itemize}")
end

function M.print_grade()
    local sorted = {}
    for _, v in ipairs(M.routes) do table.insert(sorted, v) end
    table.sort(sorted, function(a, b)
        local va = M.get_val(a.grade)
        local vb = M.get_val(b.grade)
        if math.abs(va - vb) < 0.001 then return string.lower(a.name) < string.lower(b.name) end
        return va < vb
    end)
    tex.sprint("\\begin{itemize}[label={}, leftmargin=0pt, itemsep=4pt]")
    for _, v in ipairs(sorted) do
        tex.sprint("\\item {\\CGBaseFont\\bfseries " .. v.name .. "} \\dotfill {\\small " .. v.sector .. "} \\dotfill {\\CGBaseFont\\slshape " .. v.grade .. "}~({\\small " .. v.id .. "})")
    end
    tex.sprint("\\end{itemize}")
end

return M
