package.path = package.path .. ";../src/?.lua"
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
        { grade = "A0", expected = 0.0 }, -- Artificial removed by new multipitch rules
        { grade = "7c/8a", expected = 8.1 }, -- Expect max free
        { grade = "5 Vsup (A0/VIIb)", expected = 5.5 },
        { grade = "Proj", expected = 999.0 },
        { grade = "5° VIIb", expected = 7.4 }
    }

    local failed = 0
    for _, case in ipairs(cases) do
        local result = cg.get_val(case.grade)
        if math.abs(result - case.expected) > 0.001 then
            print(string.format("[FAIL] Grade: '%s' | Expected: %s | Result: %s", case.grade, tostring(case.expected), tostring(result)))
            failed = failed + 1
        end
    end
    
    if failed > 0 then
        print(string.format("[FATAL] %d Lua assertions failed.", failed))
        os.exit(1)
    end
    print("[OK] All Lua mathematical assertions passed.")
end
run_tests()
