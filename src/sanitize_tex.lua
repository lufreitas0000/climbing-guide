local Sanitizer = {}

function Sanitizer.strip_tex_macros(str)
    if type(str) ~= "string" or str == "" then return "" end

    -- 1. Structural Bracket Nesting Guard
    local depth = 0
    for i = 1, #str do
        local c = string.sub(str, i, i)
        if c == "{" then
            depth = depth + 1
            if depth > 1 then 
                error("Sanitization Error: Nested LaTeX macros are not supported in string: '" .. str .. "'") 
            end
        elseif c == "}" then
            depth = depth - 1
            if depth < 0 then 
                error("Sanitization Error: Unmatched closing brace in string: '" .. str .. "'") 
            end
        end
    end
    if depth > 0 then 
        error("Sanitization Error: Unmatched opening brace in string: '" .. str .. "'") 
    end

    local res = str

    -- 2. Strip standard color macros entirely (they contain no printable payload)
    res = string.gsub(res, "\\color%s*%b{}", "")

    -- 3. Extract textcolor payload (requires matching two bracket groups)
    res = string.gsub(res, "\\textcolor%s*%b{}%s*(%b{})", function(payload)
        return string.sub(payload, 2, -2)
    end)

    -- 4. Extract standard formatting macro payloads
    local format_macros = {"textbf", "textit", "emph"}
    for _, macro in ipairs(format_macros) do
        res = string.gsub(res, "\\" .. macro .. "%s*(%b{})", function(payload)
            return string.sub(payload, 2, -2)
        end)
    end

    -- 5. Translate structural LaTeX spacing into standard spaces
    res = string.gsub(res, "\\\\", " ")
    res = string.gsub(res, "\\newline", " ")
    res = string.gsub(res, "~", " ")

    -- 6. Collapse redundant contiguous spaces and trim margins
    res = string.gsub(res, "%s+", " ")
    res = string.match(res, "^%s*(.-)%s*$") or res

    return res
end

return Sanitizer
