import 'CoreLibs/graphics'
import 'CoreLibs/sprites'
import 'CoreLibs/crank'
import 'constants'
import 'draw'
import 'save'
import 'log'
import 'system-menu'

local gfx = playdate.graphics
playdate.display.setRefreshRate( 30 )

gfx.setBackgroundColor( gfx.kColorWhite )

local firstRun = true

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

  DrawDemo()
end

function playdate.leftButtonDown()    Log("pressed left")        end
function playdate.rightButtonDown()   Log("pressed right")        end
function playdate.upButtonDown()      Log("pressed up")          end
function playdate.downButtonDown()    Log("pressed down")        end
function playdate.AButtonDown()       Log("pressed a")               end
function playdate.BButtonDown()       Log("pressed b")               end
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