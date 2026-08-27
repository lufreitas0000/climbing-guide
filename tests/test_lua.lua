package.path = package.path .. ";src/?.lua;../src/?.lua"
_G.tex = { sprint = function(str) _G.tex.last_sprint = (_G.tex.last_sprint or "") .. str end }
local cg = require("climbingguide")
local sorter = require("route_sorter")
local json = require("export_json")
local sanitizer = require("sanitize_tex")

local function run_tests()
    local failed = 0

    print("--- Mathematical Grade Assertions ---")
    local cases = {
        { grade = "III", expected = 3.0 },
        { grade = "IVsup", expected = 4.5 },
        { grade = "VIIa", expected = 7.1 },
        { grade = "A0", expected = 20.0 },
        { grade = "7c/8a", expected = 7.85 },
        { grade = "Proj", expected = 999.0 },
        { grade = "5° VIIb", expected = 7.4 }
    }
    for _, case in ipairs(cases) do
        local result = cg.get_val(case.grade)
        if math.abs(result - case.expected) > 0.001 then
            print(string.format("[FAIL] Grade: '%s' | Expected: %s | Result: %s", case.grade, tostring(case.expected), tostring(result)))
            failed = failed + 1
        end
    end

    print("\n--- Exception Handling Assertions ---")
    local error_cases = { "VIIb+", "5VIIb", "VII b", "4 sup" }
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
    local sorted_grade = sorter.sort_by_grade(mock_routes, cg.get_val)
    if sorted_grade[1].id ~= 3 or sorted_grade[2].id ~= 2 or sorted_grade[3].id ~= 1 or sorted_grade[4].id ~= 4 then
        print("[FAIL] sort_by_grade failed Strict Weak Ordering.")
        failed = failed + 1
    end

    print("\n--- JSON Serialization Assertions ---")
    local json_cases = {
        { input = "Line1\nLine2", expected = "Line1\\u000aLine2" },
        { input = "Control\x1bCode", expected = "Control\\u001bCode" }
    }
    for _, j_case in ipairs(json_cases) do
        local result = json.escape_string(j_case.input)
        if result ~= j_case.expected then
            print(string.format("[FAIL] JSON Escape: '%s' | Expected: '%s' | Result: '%s'", j_case.input, j_case.expected, result))
            failed = failed + 1
        end
    end

    print("\n--- Lexical Sanitization Assertions ---")
    local san_cases = {
        { input = "Route \\textbf{Name}", expected = "Route Name" },
        { input = "Line1\\\\Line2", expected = "Line1 Line2" },
        { input = "Long\\newline Route", expected = "Long Route" },
        { input = "Color \\color{guide_red} text", expected = "Color text" },
        { input = "Payload \\textcolor{blue}{colored}", expected = "Payload colored" },
        { input = "Hard~Route", expected = "Hard Route" },
        { input = "Multiple \\textit{styles} and \\emph{emphasis}", expected = "Multiple styles and emphasis" },
        { input = "  Messy    Spaces   ", expected = "Messy Spaces" }
    }
    for _, s_case in ipairs(san_cases) do
        local result = sanitizer.strip_tex_macros(s_case.input)
        if result ~= s_case.expected then
            print(string.format("[FAIL] Sanitize: '%s' | Expected: '%s' | Result: '%s'", s_case.input, s_case.expected, result))
            failed = failed + 1
        end
    end

    local nesting_status, nesting_err = pcall(sanitizer.strip_tex_macros, "\\textbf{\\textit{Nested}}")
    if nesting_status then
        print("[FAIL] Nested macro successfully passed instead of throwing an error.")
        failed = failed + 1
    end

    if failed > 0 then
        print(string.format("\n[FATAL] %d Lua assertions failed.", failed))
        os.exit(1)
    end
    print("[OK] All Lua assertions passed successfully.")
end
run_tests()
