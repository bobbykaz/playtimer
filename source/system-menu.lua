import "log"

local initialized = false
local menu = playdate.getSystemMenu()

local function HandleDarkMode(enabled)
    Log("Dark mode toggle:", enabled)
    playdate.display.setInverted(enabled)
end

local function HandleOptions(choice)
    Log("MenuItem Options choice:", choice)
end

local function HandleMenuItem() 
    Log("MenuItem Generic")
end

function InitMenu()
    if not initialized then
        local item1,err1 = menu:addCheckmarkMenuItem("Dark mode", false, HandleDarkMode)
        if item1 == nil then
            Log("error adding checkmark menu item", err1)
        end
        
        local item2,err2 = menu:addOptionsMenuItem("Option",{"Item 1","Item 2", "Item 3"}, "Item 1", HandleOptions)
        if item2 == nil then
            Log("error adding options menu item", err2)
        end

        local item3,err3 = menu:addMenuItem("Custom", HandleMenuItem)

        if item2 == nil then
            Log("error adding generic menu item", err3)
        end

        initialized = true 
    end
end
