local Sorter = {}

local function clone_table(t)
    local new_t = {}
    for _, v in ipairs(t) do
        table.insert(new_t, v)
    end
    return new_t
end

local function remove_accents(str)
    str = string.lower(str)
    str = string.gsub(str, "á", "a")
    str = string.gsub(str, "à", "a")
    str = string.gsub(str, "ã", "a")
    str = string.gsub(str, "â", "a")
    str = string.gsub(str, "é", "e")
    str = string.gsub(str, "ê", "e")
    str = string.gsub(str, "í", "i")
    str = string.gsub(str, "ó", "o")
    str = string.gsub(str, "õ", "o")
    str = string.gsub(str, "ô", "o")
    str = string.gsub(str, "ú", "u")
    str = string.gsub(str, "ç", "c")
    return str
end

function Sorter.sort_by_alpha(routes)
    local sorted = clone_table(routes)
    table.sort(sorted, function(a, b)
        local name_a = remove_accents(a.name)
        local name_b = remove_accents(b.name)
        if name_a ~= name_b then return name_a < name_b end
        
        local sec_a = remove_accents(a.sector)
        local sec_b = remove_accents(b.sector)
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
        
        local sec_a = remove_accents(a.sector)
        local sec_b = remove_accents(b.sector)
        if sec_a ~= sec_b then return sec_a < sec_b end
        
        local name_a = remove_accents(a.name)
        local name_b = remove_accents(b.name)
        if name_a ~= name_b then return name_a < name_b end
        
        return a.id < b.id
    end)
    return sorted
end

return Sorter
