local enabled = false
--disable logging in this source file for release builds
function Log(...)
    if enabled then
        print(...)
    end
end

--disable logging in this source file for release builds
function LogTable(tbl)
    if enabled then
        printTable(tbl)
    end
end