import 'CoreLibs/graphics'
import 'CoreLibs/sprites'
import 'CoreLibs/crank'
import 'constants'
import 'system-menu'
import 'stopwatch'
import 'timer'
import 'log'


local gfx = playdate.graphics
playdate.display.setRefreshRate( 30 )

gfx.setBackgroundColor( gfx.kColorWhite )

local firstRun = true
local stopWatchScreen = Stopwatch()
local timerScreen = Timer()
local currentScreen = stopWatchScreen

function ShowStopwatch()
  currentScreen:HandleExit()
  currentScreen = stopWatchScreen
end

function ShowTimer()
  currentScreen:HandleExit()
  currentScreen = timerScreen
end

function playdate.update()
  if firstRun then
    InitMenu(ShowStopwatch,ShowTimer)
    firstRun = false
  end
  currentScreen:Update()
end

function playdate.leftButtonDown()    currentScreen:HandleLeft()      end
function playdate.rightButtonDown()   currentScreen:HandleRight()     end
function playdate.upButtonDown()      currentScreen:HandleUp()        end
function playdate.downButtonDown()    currentScreen:HandleDown()      end
function playdate.AButtonDown()       currentScreen:HandleAButton()   end
function playdate.BButtonDown()       currentScreen:HandleBButton()   end
function playdate.cranked(change, acceleratedChange) 
  currentScreen:HandleCrank(change,acceleratedChange)
end

function playdate.gameWillTerminate() currentScreen:HandleExit() end
function playdate.deviceWillSleep()   currentScreen:HandleExit() end
function playdate.deviceWillLock()    currentScreen:HandleExit() end