package.path = package.path .. ";src/?.lua;../src/?.lua"
_G.tex = { sprint = function(str) _G.tex.last_sprint = (_G.tex.last_sprint or "") .. str end }
local cg = require("climbingguide")

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
        
        -- Artificial Rule Check
        { grade = "A0", expected = 20.0 },
        { grade = "A4", expected = 24.0 },
        { grade = "A5+", expected = 25.5 },
        { grade = "A4 (Via puramente em artificial)", expected = 24.0 },
        
        -- Averaging Check
        { grade = "7c/8a", expected = 7.85 },
        { grade = "4/4sup", expected = 4.25 },
        { grade = "6sup/7a", expected = 6.8 },
        
        -- Ignore parenthesis and select max
        { grade = "5 Vsup (A0/VIIb)", expected = 5.5 },
        { grade = "4 VIsup A3+", expected = 6.5 },
        { grade = "5 VIIb A2 (3)", expected = 7.4 },
        
        -- Generic mappings
        { grade = "Proj", expected = 999.0 },
        { grade = "?", expected = 999.0 },
        { grade = "7a?", expected = 7.1 },
        { grade = "5° VIIb", expected = 7.4 },
        { grade = "5o VIIb", expected = 7.4 }
    }

    local error_cases = {
        "VIIb+",    -- Plus symbol invalid here
        "5VIIb",    -- Missing space
        "VII b",    -- Space before suffix
        "4 sup"     -- Space before suffix
    }

    local failed = 0
    print("--- Mathematical Assertions ---")
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
            print(string.format("[FAIL] Grade '%s' should have thrown an error, but it passed.", bad_grade))
            failed = failed + 1
        else
            print(string.format("[OK] Caught expected error for '%s': %s", bad_grade, err))
        end
    end
    
    if failed > 0 then
        print(string.format("\n[FATAL] %d Lua assertions failed.", failed))
        os.exit(1)
    end
    print("\n[OK] All Lua mathematical and strict formatting assertions passed.")
end
run_tests()
