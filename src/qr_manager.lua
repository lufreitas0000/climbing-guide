local QR = {}
local JSON = require("export_json")
QR.registry = {}

local function djb2_hash(str)
    local h = 5381
    for i = 1, #str do
        h = (h * 33) + string.byte(str, i)
    end
    return tostring(math.abs(h))
end

function QR.register(url, info)
    local provider = "generic"
    if string.match(url, "thecrag%.com") then provider = "thecrag"
    elseif string.match(url, "wikiloc%.com") then provider = "wikiloc" end
    
    -- Extract trailing numerical ID, fallback to hash if not found
    local id = string.match(url, "(%d+)/?$")
    if not id then id = djb2_hash(url) end
    
    local safe_info = string.gsub(info, "[^%w_]", "_")
    local filename = string.format("%s_%s_%s.png", provider, safe_info, id)
    
    -- Register state for manifest generation
    table.insert(QR.registry, {
        url = url,
        filename = filename,
        provider = provider,
        info = info
    })
    
    -- Return filename to TeX engine
    tex.sprint(filename)
end

function QR.export_manifest(filepath)
    local f = io.open(filepath, "w")
    if not f then return false end
    
    f:write("[\n")
    for i, entry in ipairs(QR.registry) do
        f:write('  {\n')
        f:write('    "url": "' .. JSON.escape_string(entry.url) .. '",\n')
        f:write('    "filename": "' .. JSON.escape_string(entry.filename) .. '",\n')
        f:write('    "provider": "' .. JSON.escape_string(entry.provider) .. '",\n')
        f:write('    "info": "' .. JSON.escape_string(entry.info) .. '"\n')
        if i < #QR.registry then f:write('  },\n') else f:write('  }\n') end
    end
    f:write("]\n")
    f:close()
end

return QR
