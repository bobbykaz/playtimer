import "log"

local initialized = false
local menu = playdate.getSystemMenu()

local function HandleDarkMode(enabled)
    Log("Dark mode toggle:", enabled)
    playdate.display.setInverted(enabled)
end

function InitMenu(stopwatchFunc, timerFunc)
    if not initialized then
        local item1,err1 = menu:addCheckmarkMenuItem("Dark mode", false, HandleDarkMode)
        if item1 == nil then
            Log("error adding checkmark menu item", err1)
        end
        
        local item2,err2 = menu:addMenuItem("Stopwatch", stopwatchFunc)

        if item2 == nil then
            Log("error adding generic menu item", err2)
        end

        local item3,err3 = menu:addMenuItem("Timer", timerFunc)

        if item3 == nil then
            Log("error adding generic menu item", err3)
        end
        
        initialized = true 
    end
end
