import 'CoreLibs/graphics'
import 'CoreLibs/sprites'
import 'CoreLibs/crank'
import 'constants'
import 'save'
import 'system-menu'
import 'stopwatch'
import 'timer'
import 'log'


local gfx = playdate.graphics
playdate.display.setRefreshRate( 30 )

gfx.setBackgroundColor( gfx.kColorWhite )

local firstRun = true
local stopWatchScreen = StopwatchScreenBuilder()
local timerScreen = TimerScreenBuilder()
local currentScreen = stopWatchScreen

function loadSavedData()
  if SaveExists("example") then
    Log("Loading previously saved data",targetWord)
    local tbl =  LoadData("example")
    LogTable(tbl)
  else
    Log("no save present")
  end
end

function ShowStopwatch()
  currentScreen = stopWatchScreen
end

function ShowTimer()
  currentScreen = timerScreen
end

function playdate.update()
  if firstRun then
    loadSavedData()
    InitMenu(ShowStopwatch,ShowTimer)
    firstRun = false
  end
  currentScreen.UpdateScreen()
end

function playdate.leftButtonDown()    currentScreen.Left()      end
function playdate.rightButtonDown()   currentScreen.Right()     end
function playdate.upButtonDown()      currentScreen.Up()        end
function playdate.downButtonDown()    currentScreen.Down()      end
function playdate.AButtonDown()       currentScreen.AButton()   end
function playdate.BButtonDown()       currentScreen.BButton()   end
function playdate.cranked(change, acceleratedChange) 
  currentScreen.Crank(change,acceleratedChange)
end

function HandleSavingState(mode)
  SaveData(mode)
end

function playdate.gameWillTerminate() HandleSavingState("terminate") end
function playdate.deviceWillSleep()   HandleSavingState("sleep") end
function playdate.deviceWillLock()    HandleSavingState("lock") end