local M = {}
M.routes = {}
M.current_zone = ""
M.current_sector = ""

local Sorter = require("route_sorter")
local JSON = require("export_json")
local Sanitizer = require("sanitize_tex")
local TXT = require("export_txt")
local ZoneStats = require("zone_stats")

local romans = {"xii", "viii", "vii", "iii", "xi", "ix", "vi", "iv", "ii", "x", "v", "i"}
local roman_map = { xii=12, xi=11, x=10, ix=9, viii=8, vii=7, vi=6, v=5, iv=4, iii=3, ii=2, i=1 }

function M.set_zone(z) M.current_zone = z end
function M.set_sector(s) M.current_sector = s end

function M.register_route(id, name, grade, length, gear, setter)
    local len_s = Sanitizer.strip_tex_macros(length)
    local gear_s = Sanitizer.strip_tex_macros(gear)
    local setter_s = Sanitizer.strip_tex_macros(setter)

    table.insert(M.routes, {
        zone = Sanitizer.strip_tex_macros(M.current_zone),
        sector = Sanitizer.strip_tex_macros(M.current_sector),
        id = tonumber(id) or 0,
        name = Sanitizer.strip_tex_macros(name),
        grade = Sanitizer.strip_tex_macros(grade),
        length = (len_s == "N/A" or len_s == "") and "#m" or len_s,
        gear = (gear_s == "N/A" or gear_s == "") and "(#+2)" or gear_s,
        setter = (setter_s == "N/A" or setter_s == "") and "Conquistador(es)?" or setter_s
    })
end

function M.export_json(filepath)
    JSON.export(filepath, M.routes)
end

function M.export_text_lists(output_dir)
    TXT.export(output_dir, M.routes, M.get_val)
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
    local max_val = M.get_val(Sanitizer.strip_tex_macros(g))
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
    local sorted = Sorter.sort_by_alpha(M.routes)
    tex.sprint("\\begin{longtable}{ p{0.45\\linewidth} >{\\centering\\arraybackslash}p{0.2\\linewidth} >{\\centering\\arraybackslash}p{0.35\\linewidth} }")
    for _, v in ipairs(sorted) do
        tex.sprint(string.format("{\\CGListRouteNameFont %s} & {\\CGListGradeFont %s} & {\\CGListSectorFont %s} \\\\", v.name, v.grade, v.sector))
    end
    tex.sprint("\\end{longtable}")
end

function M.print_grade()
    local sorted = Sorter.sort_by_grade(M.routes, M.get_val)
    tex.sprint("\\begin{longtable}{ p{0.45\\linewidth} >{\\centering\\arraybackslash}p{0.2\\linewidth} >{\\centering\\arraybackslash}p{0.35\\linewidth} }")
    for _, v in ipairs(sorted) do
        tex.sprint(string.format("{\\CGListRouteNameFont %s} & {\\CGListGradeFont %s} & {\\CGListSectorFont %s} \\\\", v.name, v.grade, v.sector))
    end
    tex.sprint("\\end{longtable}")
end

function M.render_zone_stats(target_zone)
    ZoneStats.render_zone_chart(target_zone, M.routes, M.get_val)
end

function M.export_stats_aux(filepath)
    local z_stats = {}
    for _, r in ipairs(M.routes) do
        local z = r.zone
        -- Strictly filter out empty zones (e.g. from documentation specimens)
        if z and z ~= "" then
            if not z_stats[z] then z_stats[z] = {guide_cyan=0, guide_green=0, guide_yellow=0, guide_orange=0, guide_red=0, guide_purple=0, guide_gray=0} end
            local val = M.get_val(r.grade)
            if val == 999 then z_stats[z].guide_gray = z_stats[z].guide_gray + 1
            elseif val > 0 and val < 5 then z_stats[z].guide_cyan = z_stats[z].guide_cyan + 1
            elseif val >= 5 and val < 6 then z_stats[z].guide_green = z_stats[z].guide_green + 1
            elseif val >= 6 and val < 7 then z_stats[z].guide_yellow = z_stats[z].guide_yellow + 1
            elseif val >= 7 and val < 8 then z_stats[z].guide_orange = z_stats[z].guide_orange + 1
            elseif val >= 8 and val < 9 then z_stats[z].guide_red = z_stats[z].guide_red + 1
            elseif val >= 9 then z_stats[z].guide_purple = z_stats[z].guide_purple + 1
            end
        end
    end

    local f = io.open(filepath, "w")
    if f then
        f:write(string.format("\\gdef\\CGTotalRoutes{%d}\n", #M.routes))
        f:write("\\ExplSyntaxOn\n")
        for z, st in pairs(z_stats) do
            local tex_str = ""
            local colors = {"guide_cyan", "guide_green", "guide_yellow", "guide_orange", "guide_red", "guide_purple", "guide_gray"}
            for _, c in ipairs(colors) do
                if st[c] > 0 then
                    tex_str = tex_str .. string.format("\\DrawSummaryBlockSingle{%s}{%d} ", c, st[c])
                end
            end
            f:write(string.format("\\cs_gset:cpn {g_guide_stats_%s} { %s }\n", z, tex_str))
        end
        f:write("\\ExplSyntaxOff\n")
        f:close()
    end
end

return M
