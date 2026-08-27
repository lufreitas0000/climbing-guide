package.path = package.path .. ";src/?.lua;../src/?.lua"
local Sanitizer = require("sanitize_tex")

local function run_sanitizer_tests()
    local failed = 0

    print("--- TDD Sanitization Suite ---")

    local test_vectors = {
        { input = "Route \\textbf{Name}", expected = "Route Name" },
        { input = "Line1\\\\Line2", expected = "Line1 Line2" },
        { input = "Long\\newline Route", expected = "Long Route" },
        { input = "Color \\color{guide_red} text", expected = "Color text" },
        { input = "Payload \\textcolor{blue}{colored}", expected = "Payload colored" },
        { input = "Hard~Route", expected = "Hard Route" },
        { input = "Multiple \\textit{styles} and \\emph{emphasis}", expected = "Multiple styles and emphasis" },
        { input = "  Messy    Spaces   ", expected = "Messy Spaces" }
    }

    for _, vector in ipairs(test_vectors) do
        local result = Sanitizer.strip_tex_macros(vector.input)
        if result ~= vector.expected then
            print(string.format("[FAIL] Input: '%s' | Expected: '%s' | Result: '%s'", vector.input, vector.expected, result))
            failed = failed + 1
        end
    end

    local nesting_status, _ = pcall(Sanitizer.strip_tex_macros, "\\textbf{\\textit{Nested}}")
    if nesting_status then
        print("[FAIL] Nested macro successfully passed instead of throwing an error.")
        failed = failed + 1
    end

    local unmatched_open_status, _ = pcall(Sanitizer.strip_tex_macros, "\\textbf{Unclosed")
    if unmatched_open_status then
        print("[FAIL] Unmatched opening brace passed instead of throwing an error.")
        failed = failed + 1
    end

    if failed > 0 then
        print(string.format("\n[FATAL] %d Sanitization assertions failed.", failed))
        os.exit(1)
    end
    print("[OK] All Sanitization assertions passed successfully.")
end

run_sanitizer_tests()
