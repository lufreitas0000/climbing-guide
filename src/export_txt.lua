local TXT = {}
local Sorter = require("route_sorter")

local function pad(val)
    if val == nil or string.match(tostring(val), "^%s*$") then
        return "N/A"
    end
    return tostring(val)
end

local function write_list(filepath, sorted_routes)
    local f = io.open(filepath, "w")
    if not f then return false end
    
    for _, r in ipairs(sorted_routes) do
        local line = string.format("%s | %s | %s | %s | %s | %s | %s | %s | %s\n",
            pad(r.id), pad(r.name), pad(r.grade), pad(r.stars), pad(r.length), pad(r.gear), pad(r.setter), pad(r.sector), pad(r.zone))
        f:write(line)
    end
    
    f:close()
    return true
end

function TXT.export(output_dir, routes, grade_eval_func)
    local sorted_alpha = Sorter.sort_by_alpha(routes)
    local sorted_grade = Sorter.sort_by_grade(routes, grade_eval_func)

    write_list(output_dir .. "list_alpha.txt", sorted_alpha)
    write_list(output_dir .. "list_grade.txt", sorted_grade)
end

return TXT
