local M = {}
M.routes = {}
M.current_zone = ""
M.current_sector = ""

local romans = {"xii", "viii", "vii", "iii", "xi", "ix", "vi", "iv", "ii", "x", "v", "i"}
local roman_map = { xii=12, xi=11, x=10, ix=9, viii=8, vii=7, vi=6, v=5, iv=4, iii=3, ii=2, i=1 }

function M.set_zone(z) M.current_zone = z end
function M.set_sector(s) M.current_sector = s end

function M.register_route(id, name, grade, length, gear, setter)
    table.insert(M.routes, {
        zone = M.current_zone,
        sector = M.current_sector,
        id = tonumber(id) or 0,
        name = name,
        grade = grade,
        length = length,
        gear = gear,
        setter = setter
    })
end

local function escape_json(str)
    if type(str) ~= "string" then return "" end
    str = string.gsub(str, "\\", "\\\\")
    str = string.gsub(str, '"', '\\"')
    str = string.gsub(str, "\n", "\\n")
    str = string.gsub(str, "\r", "\\r")
    str = string.gsub(str, "\t", "\\t")
    return str
end

function M.export_json(filepath)
    local f = io.open(filepath, "w")
    if not f then return end
    f:write("[\n")
    for i, r in ipairs(M.routes) do
        f:write('  {\n')
        f:write('    "zone": "' .. escape_json(r.zone) .. '",\n')
        f:write('    "sector": "' .. escape_json(r.sector) .. '",\n')
        f:write('    "id": ' .. tostring(r.id) .. ',\n')
        f:write('    "name": "' .. escape_json(r.name) .. '",\n')
        f:write('    "grade": "' .. escape_json(r.grade) .. '",\n')
        f:write('    "length": "' .. escape_json(r.length) .. '",\n')
        f:write('    "gear": "' .. escape_json(r.gear) .. '",\n')
        f:write('    "setter": "' .. escape_json(r.setter) .. '"\n')
        if i < #M.routes then f:write('  },\n') else f:write('  }\n') end
    end
    f:write("]\n")
    f:close()
end

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

local function calc_free_grade(text)
    local g1, g2 = string.match(text, "([%w]+)%s*/%s*([%w]+)")
    if g1 and g2 then
        local v1 = parse_grade(g1)
        local v2 = parse_grade(g2)
        if v1 > 0 and v2 > 0 then return (v1 + v2) / 2.0 end
    end

    local max_f = 0
    for token in string.gmatch(text, "[a-z0-9]+") do
        if not string.match(token, "^[eda]%d+") then
            local val = parse_grade(token)
            if val > max_f then max_f = val end
        end
    end
    return max_f
end

function M.get_val(g)
    local g_low = string.lower(g)
    if string.match(g_low, "proj") or string.match(g_low, "^%s*%%%?%s*$") or string.match(g_low, "^%?+$") then return 999 end

    local tmp_plus = string.gsub(g_low, "a%d+%+", "")
    if string.match(tmp_plus, "%+") then error("Invalid format: '+' only allowed in artificial grades (" .. g .. ")") end
    if string.match(g_low, "%d+[°ºo]?[ivx]+") then error("Invalid format: Missing space after general grade (" .. g .. ")") end
    if string.match(g_low, "[ivx%d]%s+[abc]%f[%W]") or string.match(g_low, "[ivx%d]%s+sup%f[%W]") then error("Invalid format: Space not allowed between base grade and suffix (" .. g .. ")") end

    g_low = string.gsub(g_low, "%d+[°ºo]", " ")
    local outside = string.gsub(g_low, "%(.-%)", " ")

    local val_out = calc_free_grade(outside)
    if val_out > 0 then return val_out end

    local max_art = 0
    for num, plus in string.gmatch(g_low, "a(%d+)(%+?)") do
        local val = 20.0 + tonumber(num)
        if plus == "+" then val = val + 0.5 end
        if val > max_art then max_art = val end
    end
    if max_art > 0 then return max_art end

    return 999
end

function M.eval_tex(g)
    local max_val = M.get_val(g)
    if max_val == 999 then 
        tex.sprint("\\CGEvalGrade{guide_gray}{gray}")
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
    elseif max_val >= 9 and max_val < 20 then color, base = "guide_purple", "purple"
    end

    if base ~= "gray" and not is_top then color = color .. "!60!black" end
    local top_str = is_top and "_top" or "_bot"

    if base ~= "gray" then 
        tex.sprint("\\CGEvalGrade{" .. color .. "}{" .. base .. top_str .. "}")
    else
        tex.sprint("\\CGEvalGrade{" .. color .. "}{}")
    end
end

function M.print_alpha()
    local sorted = {}
    for _, v in ipairs(M.routes) do table.insert(sorted, v) end
    table.sort(sorted, function(a, b) return string.lower(a.name) < string.lower(b.name) end)
    tex.sprint("\\begin{itemize}[label={}, leftmargin=0pt, itemsep=4pt]")
    for _, v in ipairs(sorted) do tex.sprint("\\item {\\CGBaseFont\\bfseries " .. v.name .. "} \\dotfill {\\small " .. v.sector .. "} \\dotfill {\\CGBaseFont\\slshape " .. v.grade .. "}~({\\small " .. v.id .. "})") end
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
    for _, v in ipairs(sorted) do tex.sprint("\\item {\\CGBaseFont\\bfseries " .. v.name .. "} \\dotfill {\\small " .. v.sector .. "} \\dotfill {\\CGBaseFont\\slshape " .. v.grade .. "}~({\\small " .. v.id .. "})") end
    tex.sprint("\\end{itemize}")
end

return M
