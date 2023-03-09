import 'CoreLibs/graphics'
import 'CoreLibs/object'
import 'CoreLibs/sprites'
import 'log'

class('Screen').extends()

function Screen:init()
    Screen.super.init(self)
end

function Screen:HandleAButton() Log("A button pressed") end
function Screen:HandleBButton() Log("B button pressed") end
function Screen:HandleUp()    Log("Up pressed")         end
function Screen:HandleDown()  Log("Down pressed")       end
function Screen:HandleLeft()  Log("Left pressed")       end
function Screen:HandleRight() Log("Right pressed")      end
function Screen:HandleCrank(change, accelChange)
    local ticks = playdate.getCrankTicks(6)
    Log("Crank: change", change, "accel", accelChange, "ticks", ticks)
end

function Screen:HandleExit() Log("Exiting base screen") end
function Screen:HandleUpdate() Log("Base Screen Update") end

