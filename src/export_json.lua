local Serializer = {}
local Sanitizer = require("sanitize_tex")

-- Public function to allow strict TDD validation of the sanitization rules
function Serializer.escape_string(str)
    if type(str) ~= "string" then return "" end
    
    -- 0. Transform LaTeX-safe escapes to API plain text
    str = Sanitizer.unescape_tex(str)
    
    -- 1. Escape JSON structural characters
    str = string.gsub(str, "\\", "\\\\")
    str = string.gsub(str, '"', '\\"')
    
    -- 2. Universally hex-escape all ASCII control characters (U+0000 to U+001F)
    str = string.gsub(str, "[\0-\31]", function(c)
        return string.format("\\u%04x", string.byte(c))
    end)
    
    return str
end

function Serializer.export(filepath, routes)
    local f = io.open(filepath, "w")
    if not f then return false end
    
    f:write("[\n")
    for i, r in ipairs(routes) do
        f:write('  {\n')
        f:write('    "zone": "' .. Serializer.escape_string(r.zone) .. '",\n')
        f:write('    "sector": "' .. Serializer.escape_string(r.sector) .. '",\n')
        f:write('    "id": ' .. tostring(r.id) .. ',\n')
        f:write('    "name": "' .. Serializer.escape_string(r.name) .. '",\n')
        f:write('    "grade": "' .. Serializer.escape_string(r.grade) .. '",\n')
        f:write('    "stars": ' .. tostring(r.stars) .. ',\n')
        f:write('    "length": "' .. Serializer.escape_string(r.length) .. '",\n')
        f:write('    "gear": "' .. Serializer.escape_string(r.gear) .. '",\n')
        f:write('    "setter": "' .. Serializer.escape_string(r.setter) .. '"\n')
        
        if i < #routes then
             f:write('  },\n')
         else
             f:write('  }\n')
         end
    end
    f:write("]\n")
    
    f:close()
    return true
end

return Serializer
