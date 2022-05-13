
import 'CoreLibs/graphics'
import 'constants'

local gfx = playdate.graphics

local kState = {
    running = 0,
    stopping = 1,
    stopped = 2
}

local fntClock = gfx.font.new("fonts/7-Segment")
local fntBasic = gfx.font.new("fonts/Asheville-Sans-14-Light")
local watchState = kState.stopped
local timeStartS,timeStartMs = 0,0
local elapsedMs = 0.0
local deltaMs = 0.0
local laps = {}
local newLap = false
local tempLapMs = 0
local newLapS,newLapMs = 0,0
local stopS,stopMs = 0,0

local function StartTimer()
    playdate.setAutoLockDisabled(true)
    timeStartS,timeStartMs = playdate.getSecondsSinceEpoch()
    watchState = kState.running
    Log("Start time", timeStartS,timeStartMs)
end

local function StopTimer()
    playdate.setAutoLockDisabled(false)
    stopS,stopMs = playdate.getSecondsSinceEpoch()
    watchState = kState.stopping
end

local function ResetTimer()
    watchState = kState.stopped
    timeStartS,timeStartMs = 0,0
    elapsedMs = 0.0
    deltaMs = 0.0
    laps = {}
end

local function Lap()
    if #laps < 10 then
        newLapS,newLapMs = playdate.getSecondsSinceEpoch()
        newLap = true
    end
end

local function GetTimeString(durationMs)
    local t = math.floor(durationMs)
    local ms = t % 1000
    local seconds = (t // 1000) % 60
    local minutes = (t // 60000) % 60
    local hours = (t // 3600000) % 60
    
    local timeString = ""
    if hours > 0 then
        timeString = "0"..hours..":"
    end

    if minutes < 10 then
        timeString = timeString.."0"..minutes
    else 
        timeString = timeString..""..minutes
    end

    if seconds < 10 then
        timeString = timeString..":0"..seconds.."."
    else 
        timeString = timeString..":"..seconds.."."
    end

    if ms < 10 then
        timeString = timeString.."00"..ms
    elseif ms < 100 then
        timeString = timeString.."0"..ms
    else
        timeString = timeString..ms
    end
    return timeString
end

local helpDrawX, helpDrawY = 60,205
local function DrawHelp()
    if watchState == kState.running then
        fntBasic:drawTextAligned("Ⓑ STOP", helpDrawX, helpDrawY, kTextAlignment.left)
        if #laps <10 then
            fntBasic:drawTextAligned("Ⓐ LAP", 400 - helpDrawX, helpDrawY, kTextAlignment.right)
        end
    else 
        fntBasic:drawTextAligned("Ⓑ RESET", helpDrawX, helpDrawY, kTextAlignment.left)
        fntBasic:drawTextAligned("Ⓐ START", 400 - helpDrawX, helpDrawY, kTextAlignment.right)
    end
end

local lapHeadingX,lapTimeX,lapDrawY = 20,100,100
local lapCol2XOffset = 200
local lapRowWidth = fntBasic:getHeight() + 1
local function DrawLaps()
    local i = 1
    for i=1,#laps,1 
    do
        if i <= 5 then
            fntBasic:drawTextAligned("Lap "..i..":", lapHeadingX, lapDrawY + (i-1)*lapRowWidth, kTextAlignment.left)
            fntBasic:drawTextAligned(laps[i], lapTimeX, lapDrawY + (i-1)*lapRowWidth, kTextAlignment.left)
        else
            fntBasic:drawTextAligned("Lap "..i..":", lapCol2XOffset + lapHeadingX, lapDrawY + (i-6)*lapRowWidth, kTextAlignment.left)
            fntBasic:drawTextAligned(laps[i], lapCol2XOffset + lapTimeX, lapDrawY + (i-6)*lapRowWidth, kTextAlignment.left)
        end
    end
end

local mainDrawX,mainDrawY = 80,15
local function Draw()
    --Log("Draw start: elapsed", elapsedMs, "delta", deltaMs)
    local totalMs = elapsedMs + deltaMs
    local timeString = GetTimeString(totalMs)
    --Log(timeString)
    gfx.setColor( gfx.kColorWhite )
    gfx.fillRect(0,0,400,240)

    gfx.setColor( gfx.kColorBlack )
    --Main display
    fntClock:drawTextAligned(timeString, mainDrawX, mainDrawY, kTextAlignment.left)
    -- laps
    DrawLaps()
    -- help
    DrawHelp()
end

local function Update()
    if newLap then
        local lapDelta = (newLapS - timeStartS) * 1000 + (newLapMs - timeStartMs) + tempLapMs
        local lapTime = GetTimeString(lapDelta)
        Log("lap",lapDelta,lapTime)
        table.insert(laps, lapTime)
        elapsedMs += lapDelta
        timeStartS,timeStartMs = newLapS,newLapMs
        deltaMs = 0
        tempLapMs = 0
        newLap = false
    end

    if watchState == kState.running then
        local cS,cMs = playdate.getSecondsSinceEpoch()
        deltaMs = (cS - timeStartS) * 1000 + (cMs - timeStartMs)
        --Log(timeStartS,timeStartMs, deltaMs)
    elseif watchState == kState.stopping then
        deltaMs = (stopS - timeStartS) * 1000 + (stopMs - timeStartMs)
        Log("stopping",timeStartS,timeStartMs, deltaMs)
        elapsedMs += deltaMs
        tempLapMs += deltaMs
        deltaMs = 0
        watchState = kState.stopped
        Log("timer stopped", elapsedMs)
    end
    Draw()
end

local beepInst = nil
local beepSeq = nil
local function InitSounds()
    local beepSnd = playdate.sound.synth.new(playdate.sound.kWaveSawtooth)
    beepSnd:setADSR(0,1,1,0)
    beepSeq = playdate.sound.sequence.new()
    local track = playdate.sound.track.new()
    beepInst = playdate.sound.instrument.new(beepSnd)
    beepInst:setVolume(1.0)
    track:addNote(1, "B7", 1)
    track:addNote(2, "F7", 1)
    track:setInstrument(beepInst)
    beepSeq:setTempo(10)
    beepSeq:addTrack(track)
    --beepSeq:setLoops(1, 2, 1)
end

local function PlayStartBeep()
    beepInst:playNote(3951, 1.0,0.1)
end

local function PlayStopBeep()
    beepInst:playNote(2793, 1.0,0.1)
end

local function PlayResetBeep()
    beepSeq:play()
end

local function HandleAButton()
    
    if watchState == kState.running then
        Log("A button - Lapping")
        Lap()
    else
        Log("A button - starting")
        PlayStartBeep()
        StartTimer()
    end
end

local function HandleBButton()
    if watchState == kState.running then
        Log("B button - stopping")
        PlayStopBeep()
        StopTimer()
    else
        Log("B button - resetting")
        PlayResetBeep()
        ResetTimer()
    end
end

local function DoNothing()
end

local function HandleCrank(change, accelChange)
end

function StopwatchScreenBuilder()
    InitSounds()
    local screen = {
        AButton = HandleAButton,
        BButton = HandleBButton,
        Down = DoNothing,
        Up = DoNothing,
        Left = DoNothing,
        Right = DoNothing,
        Crank = HandleCrank,
        UpdateScreen = Update
    }

    return screen
end
