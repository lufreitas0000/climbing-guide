local Sorter = {}

local function clone_table(t)
    local new_t = {}
    for _, v in ipairs(t) do
        table.insert(new_t, v)
    end
    return new_t
end

function Sorter.sort_by_alpha(routes)
    local sorted = clone_table(routes)
    table.sort(sorted, function(a, b)
        local name_a = string.lower(a.name)
        local name_b = string.lower(b.name)
        if name_a ~= name_b then return name_a < name_b end
        
        local sec_a = string.lower(a.sector)
        local sec_b = string.lower(b.sector)
        if sec_a ~= sec_b then return sec_a < sec_b end
        
        return a.id < b.id
    end)
    return sorted
end

function Sorter.sort_by_grade(routes, grade_eval_func)
    local sorted = clone_table(routes)
    table.sort(sorted, function(a, b)
        local va = grade_eval_func(a.grade)
        local vb = grade_eval_func(b.grade)
        if math.abs(va - vb) > 0.001 then return va < vb end
        
        local sec_a = string.lower(a.sector)
        local sec_b = string.lower(b.sector)
        if sec_a ~= sec_b then return sec_a < sec_b end
        
        local name_a = string.lower(a.name)
        local name_b = string.lower(b.name)
        if name_a ~= name_b then return name_a < name_b end
        
        return a.id < b.id
    end)
    return sorted
end

return Sorter
