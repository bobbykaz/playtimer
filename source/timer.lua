
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
local selectedEditState = kEditState.s
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
    track:addNote(1, "B7", 1)
    track:addNote(5, "B7", 1)
    track:addNote(9, "B7", 1)
    track:addNote(13, "B7", 1)

    track:addNote(21, "B7", 1)
    track:addNote(25, "B7", 1)
    track:addNote(29, "B7", 1)
    track:addNote(33, "B7", 1)
    
    track:addNote(41, "B7", 1)
    track:addNote(45, "B7", 1)
    track:addNote(49, "B7", 1)
    track:addNote(53, "B7", 1)

    track:addNote(61, "B7", 1)
    track:addNote(65, "B7", 1)
    track:addNote(69, "B7", 1)
    track:addNote(73, "B7", 1)
    track:setInstrument(beepInst)
    beepSeq:setTempo(20)
    beepSeq:addTrack(track)
    --beepSeq:setLoops(1, 20, 5)
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
    if(timers[selectedTimer].durationMs > 0) then 
        playdate.setAutoLockDisabled(true)
        timers[selectedTimer].timeStartS,timers[selectedTimer].timeStartMs = playdate.getSecondsSinceEpoch()
        timers[selectedTimer].state = kState.running
        PlayStartBeep()
    end
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
    PlayStopBeep()
end

local function EditTimer()
    timers[selectedTimer].state = kState.editing
end

local function IncrementTimer(inc)
    inc = inc or false
    local amt = 1000
    if not inc then amt = -1000 end

    if timers[selectedTimer].state == kState.editing then
        if selectedEditState == kEditState.h then
            amt *= 3600
        elseif selectedEditState == kEditState.m then
            amt *= 60
        end
        timers[selectedTimer].durationMs += amt
        if timers[selectedTimer].durationMs < 0 then
            timers[selectedTimer].durationMs -= amt
        end

        if timers[selectedTimer].durationMs > 359999000 then
            timers[selectedTimer].durationMs -= amt
        end
    end
end

local helpDrawX, helpDrawY = 60,210
local function DrawHelp()
    if timers[selectedTimer].state == kState.running then
        fntBasic:drawTextAligned("Ⓐ/Ⓑ STOP", helpDrawX, helpDrawY, kTextAlignment.left)
    elseif timers[selectedTimer].state == kState.stopped then
        fntBasic:drawTextAligned("Ⓑ EDIT", helpDrawX, helpDrawY, kTextAlignment.left)
        fntBasic:drawTextAligned("Ⓐ START", 400 - helpDrawX, helpDrawY, kTextAlignment.right)
    elseif timers[selectedTimer].state == kState.editing then
        fntBasic:drawTextAligned("Ⓐ/Ⓑ SAVE", helpDrawX, helpDrawY, kTextAlignment.left)--
        fntBasic:drawTextAligned("✛/🎣 ADJUST", 400 - helpDrawX, helpDrawY, kTextAlignment.right)
    end
end

local mainDrawX,mainDrawY = 80,5
local drawRowYOffset = 66
local selectorOffsetX = 320
local selectorYTable = {35, 101,167}
local highLightTable = {
    {
        [kEditState.h] = playdate.geometry.rect.new( 79, 6, 66,62),
        [kEditState.m] = playdate.geometry.rect.new(155, 6, 66,62),
        [kEditState.s] = playdate.geometry.rect.new(231, 6, 66,62)
    },
    {
        [kEditState.h] = playdate.geometry.rect.new( 79, 72, 66,62),
        [kEditState.m] = playdate.geometry.rect.new(155, 72, 66,62),
        [kEditState.s] = playdate.geometry.rect.new(231, 72, 66,62)
    },
    {
        [kEditState.h] = playdate.geometry.rect.new( 79, 138, 66,62),
        [kEditState.m] = playdate.geometry.rect.new(155, 138, 66,62),
        [kEditState.s] = playdate.geometry.rect.new(231, 138, 66,62)
    }
}
local function Draw()
    --Log("Draw start: elapsed", elapsedMs, "delta", deltaMs)
    gfx.setColor( gfx.kColorWhite )
    gfx.fillRect(0,0,400,240)

    gfx.setColor( gfx.kColorBlack )
    for i=1,#timers,1
    do
        local timeString = GetTimeString(GetTimeComponents(timers[i].durationMs),true,true)
        --Log(i,timeString)
        --highlights
        --19,6 -> 66x62
        --Main display
        fntClock:drawTextAligned(timeString, mainDrawX, mainDrawY + drawRowYOffset*(i-1), kTextAlignment.left)
        if timers[i].state == kState.editing then
            gfx.setColor( gfx.kColorXOR)
            gfx.fillRect(highLightTable[i][selectedEditState])
            gfx.setColor( gfx.kColorBlack )
        end
    end
    --selector
    gfx.fillCircleAtPoint(selectorOffsetX, selectorYTable[selectedTimer],5)
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
    
    if timers[selectedTimer].state ~= kState.stopped then
        StopTimer()
    else
        Log("A button - starting")
        StartTimer()
    end
end

local function HandleBButton()
    if timers[selectedTimer].state ~= kState.stopped then
        Log("B button - stopping")
        StopTimer()
    elseif timers[selectedTimer].state == kState.stopped then
        EditTimer()
    end
end

local function CycleEditState(right)
    right = right or false
    if selectedEditState == kEditState.s then
        if(right) then 
            selectedEditState = kEditState.h
        else
            selectedEditState = kEditState.m
        end
    elseif selectedEditState == kEditState.m then
        if(right) then 
            selectedEditState = kEditState.s
        else
            selectedEditState = kEditState.h
        end
    elseif selectedEditState == kEditState.h then
        if(right) then 
            selectedEditState = kEditState.m
        else
            selectedEditState = kEditState.s
        end
    end
end

local function CycleTimerSelection(down)
    down = down or false
    if down then
        selectedTimer += 1
    else
        selectedTimer -= 1    
    end
    
    if selectedTimer > 3 then
        selectedTimer = 1
    end

    if selectedTimer < 1 then
        selectedTimer = 3
    end
end

local function HandleDpad(dir)
    if timers[selectedTimer].state == kState.editing then
        if dir == "U" then
            IncrementTimer(true)
        elseif dir == "D" then
            IncrementTimer(false)
        elseif dir == "L" then
            CycleEditState(false)
        elseif dir == "R" then
            CycleEditState(true)
        end
    else
        if dir == "U" then
            CycleTimerSelection(false)
        elseif dir == "D" then
            CycleTimerSelection(true)
        end
    end
end

local function HandleUp()    HandleDpad("U") end
local function HandleDown()  HandleDpad("D") end
local function HandleLeft()  HandleDpad("L") end
local function HandleRight() HandleDpad("R") end

local function HandleCrank(change, accelChange)
    if timers[selectedTimer].state == kState.editing then
        local ticks = playdate.getCrankTicks(12)
        if ticks == 1 then
            IncrementTimer(true)
        elseif ticks == -1 then
            IncrementTimer(false)
        end
    end
end

function TimerScreenBuilder()
    Init()
    InitSounds()
    local screen = {
        AButton = HandleAButton,
        BButton = HandleBButton,
        Down = HandleDown,
        Up = HandleUp,
        Left = HandleLeft,
        Right = HandleRight,
        Crank = HandleCrank,
        UpdateScreen = Update
    }

    return screen
end
