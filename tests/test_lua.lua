package.path = package.path .. ";src/?.lua;../src/?.lua"
_G.tex = { sprint = function(str) _G.tex.last_sprint = (_G.tex.last_sprint or "") .. str end }
local cg = require("climbingguide")
local sorter = require("route_sorter")
local json = require("export_json")

local function run_tests()
    local cases = {
        { grade = "III", expected = 3.0 },
        { grade = "IVsup", expected = 4.5 },
        { grade = "VIIa", expected = 7.1 },
        { grade = "IXc", expected = 9.6 },
        { grade = "4 V", expected = 5.0 },
        { grade = "6 VIIa", expected = 7.1 },
        { grade = "IV E3", expected = 4.0 },
        { grade = "6 VIIIa E5", expected = 8.1 },
        { grade = "E2 V", expected = 5.0 },
        { grade = "5 VIIb A2", expected = 7.4 },
        { grade = "A0", expected = 20.0 },
        { grade = "A4", expected = 24.0 },
        { grade = "A5+", expected = 25.5 },
        { grade = "A4 (Via puramente em artificial)", expected = 24.0 },
        { grade = "7c/8a", expected = 7.85 },
        { grade = "4/4sup", expected = 4.25 },
        { grade = "6sup/7a", expected = 6.8 },
        { grade = "5 Vsup (A0/VIIb)", expected = 5.5 },
        { grade = "4 VIsup A3+", expected = 6.5 },
        { grade = "5 VIIb A2 (3)", expected = 7.4 },
        { grade = "Proj", expected = 999.0 },
        { grade = "?", expected = 999.0 },
        { grade = "7a?", expected = 7.1 },
        { grade = "5° VIIb", expected = 7.4 },
        { grade = "5o VIIb", expected = 7.4 }
    }

    local error_cases = {
        "VIIb+", "5VIIb", "VII b", "4 sup"
    }

    local failed = 0
    print("--- Mathematical Grade Assertions ---")
    for _, case in ipairs(cases) do
        local result = cg.get_val(case.grade)
        if math.abs(result - case.expected) > 0.001 then
            print(string.format("[FAIL] Grade: '%s' | Expected: %s | Result: %s", case.grade, tostring(case.expected), tostring(result)))
            failed = failed + 1
        end
    end
    
    print("\n--- Exception Handling Assertions ---")
    for _, bad_grade in ipairs(error_cases) do
        local status, err = pcall(cg.get_val, bad_grade)
        if status then
            print(string.format("[FAIL] Grade '%s' should have thrown an error.", bad_grade))
            failed = failed + 1
        end
    end

    print("\n--- Sorting Pure Functions Assertions ---")
    local mock_routes = {
        { id = 1, name = "Zebra", sector = "Beta", grade = "VIIa" },
        { id = 2, name = "Alpha", sector = "Alpha", grade = "VIIa" },
        { id = 3, name = "Beta", sector = "Alpha", grade = "V" },
        { id = 4, name = "Alpha", sector = "Alpha", grade = "IXa" }
    }

    local sorted_alpha = sorter.sort_by_alpha(mock_routes)
    if sorted_alpha[1].name ~= "Alpha" or sorted_alpha[2].name ~= "Alpha" or sorted_alpha[4].name ~= "Zebra" then
        print("[FAIL] sort_by_alpha failed lexical ordering.")
        failed = failed + 1
    end
    
    if mock_routes[1].id ~= 1 then
        print("[FAIL] sort functions mutated original input table.")
        failed = failed + 1
    end

    local sorted_grade = sorter.sort_by_grade(mock_routes, cg.get_val)
    if sorted_grade[1].id ~= 3 or sorted_grade[2].id ~= 2 or sorted_grade[3].id ~= 1 or sorted_grade[4].id ~= 4 then
        print("[FAIL] sort_by_grade failed Strict Weak Ordering.")
        failed = failed + 1
    end

    print("\n--- JSON Serialization Assertions ---")
    local json_cases = {
        { input = "Line1\nLine2", expected = "Line1\\u000aLine2" },
        { input = "Data\tValue", expected = "Data\\u0009Value" },
        { input = "Return\r", expected = "Return\\u000d" },
        { input = "Quote\"Escape\\", expected = "Quote\\\"Escape\\\\" },
        { input = "Control\x1bCode", expected = "Control\\u001bCode" }, -- ESC character mapping
        { input = "Null\0Byte", expected = "Null\\u0000Byte" }
    }

    for _, j_case in ipairs(json_cases) do
        local result = json.escape_string(j_case.input)
        if result ~= j_case.expected then
            print(string.format("[FAIL] JSON Escape: '%s' | Expected: '%s' | Result: '%s'", j_case.input, j_case.expected, result))
            failed = failed + 1
        end
    end

    if failed > 0 then
        print(string.format("\n[FATAL] %d Lua assertions failed.", failed))
        os.exit(1)
    end
    print("[OK] All Lua mathematical and strict formatting assertions passed.")
end
run_tests()
