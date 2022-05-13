
import 'CoreLibs/graphics'
import 'common'
import 'constants'

local gfx = playdate.graphics

local kState = {
    running = 0,
    stopped = 1,
    editing = 2
}

local kEditState = {
    h = 0,
    m = 1,
    s = 2
}

local fntClock = gfx.font.new("fonts/7-Segment")
local fntBasic = gfx.font.new("fonts/Asheville-Sans-14-Light")

local function BuildTimer()
    local t = {
        state = kState.stopped,
        timeStartS = 0,
        timeStartMs = 0,
        durationMs = 0
    }
    return t
end
local timers = {}
local selectedTimer = 1
local function Init()
    timers = {}
    selectedTimer = 1
    local t1 = BuildTimer()
    local t2 = BuildTimer()
    local t3 = BuildTimer()
    table.insert(timers,t1)
    table.insert(timers,t2)
    table.insert(timers,t3)
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
    track:addNote(8, "B7", 1)
    track:addNote(12, "B7", 1)
    track:addNote(16, "B7", 1)
    track:addNote(20, "B7", 1)
    track:addNote(28, "B7", 1)
    track:addNote(32, "B7", 1)
    track:addNote(36, "B7", 1)
    track:addNote(40, "B7", 1)
    track:addNote(48, "B7", 1)
    track:addNote(52, "B7", 1)
    track:addNote(56, "B7", 1)
    track:addNote(60, "B7", 1)
    track:setInstrument(beepInst)
    beepSeq:setTempo(15)
    beepSeq:addTrack(track)
    beepSeq:setLoops(1, 20, 5)
end

local function PlayStartBeep()
    beepInst:playNote(3951, 1.0,0.1)
end

local function PlayStopBeep()
    beepInst:playNote(2793, 1.0,0.1)
end

local function PlayFinishBeep()
    beepSeq:play()
end

local function StartTimer()
    playdate.setAutoLockDisabled(true)
    timers[selectedTimer].timeStartS,timers[selectedTimer].timeStartMs = playdate.getSecondsSinceEpoch()
    timers[selectedTimer].state = kState.running
end

local function AllTimersStopped()
    return (timers[1].state == kState.stopped 
    and timers[2].state == kState.stopped 
    and timers[3].state == kState.stopped )
end

local function StopTimer()
    if AllTimersStopped() then
        playdate.setAutoLockDisabled(false)    
    end
    timers[selectedTimer].state = kState.stopped
end

local function IncrementTimer()
    if timers[selectedTimer].state == kState.editing then
        
    end
end

local helpDrawX, helpDrawY = 60,210
local function DrawHelp()
    if watchState == kState.running then
        fntBasic:drawTextAligned("Ⓐ/Ⓑ STOP", helpDrawX, helpDrawY, kTextAlignment.left)
    else 
        fntBasic:drawTextAligned("Ⓑ EDIT", helpDrawX, helpDrawY, kTextAlignment.left)
        fntBasic:drawTextAligned("Ⓐ START", 400 - helpDrawX, helpDrawY, kTextAlignment.right)
    end
end

local mainDrawX,mainDrawY = 20,5
local drawRowYOffset = 66
local function Draw()
    --Log("Draw start: elapsed", elapsedMs, "delta", deltaMs)
    gfx.setColor( gfx.kColorWhite )
    gfx.fillRect(0,0,400,240)

    gfx.setColor( gfx.kColorBlack )
    for i=1,#timers,1
    do
        local timeString = GetTimeString(GetTimeComponents(timers[i].durationMs))
        --Log(timeString)
        --Main display
        fntClock:drawTextAligned(timeString, mainDrawX, mainDrawY + drawRowYOffset*(i-1), kTextAlignment.left)
    end
    
    -- help
    DrawHelp()
end

local function Update()
    for i=1,#timers,1
    do
        if timers[i].state == kState.running then
            local cS,cMs = playdate.getSecondsSinceEpoch()
            local deltaMs = (cS - timers[i].timeStartS)*1000 + (cMs - timers[i].timeStartMs)
            timers[i].durationMs -= deltaMs
            if timers[i].durationMs < 0 then
                timers[i].durationMs = 0
                timers[i].state = kState.stopped
                PlayFinishBeep()
            end
            timers[i].timeStartS = cS
            timers[i].timeStartMs = cMs
        end
    end
    Draw()
end

local function HandleAButton()
    
    if timers[selectedTimer].state == kState.running then
        StopTimer()
    else
        Log("A button - starting")
        PlayStartBeep()
        StartTimer()
    end
end

local function HandleBButton()
    if timers[selectedTimer] ~= kState.stopped then
        Log("B button - stopping")
        PlayStopBeep()
        StopTimer()
    end
end

local function DoNothing()
end

local function HandleCrank(change, accelChange)
end

function TimerScreenBuilder()
    Init()
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
