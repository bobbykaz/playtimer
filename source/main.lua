import 'CoreLibs/graphics'
import 'CoreLibs/sprites'
import 'CoreLibs/crank'
import 'constants'
import 'draw'
import 'save'
import 'stopwatch'
import 'log'
import 'system-menu'

local gfx = playdate.graphics
playdate.display.setRefreshRate( 30 )

gfx.setBackgroundColor( gfx.kColorWhite )

local firstRun = true
local currentScreen = StopwatchScreenBuilder()


function loadSavedData()
  if SaveExists("example") then
    Log("Loading previously saved data",targetWord)
    local tbl =  LoadData("example")
    LogTable(tbl)
  else
    Log("no save present")
  end
end

function playdate.update()
  if firstRun then
    loadSavedData()
    InitMenu()
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
  local ticks = playdate.getCrankTicks(6)
  if ticks == 1 then
    Log("crank ticked forward")
  elseif ticks == -1 then
    Log("crank ticked backward")
  end
end

function HandleSavingState(mode)
  SaveData(mode)
end

function playdate.gameWillTerminate() HandleSavingState("terminate") end
function playdate.deviceWillSleep()   HandleSavingState("sleep") end
function playdate.deviceWillLock()    HandleSavingState("lock") end