
local running = false
local timeStart = 0.0
local elapsedTime = 0.0
local deltaTime = 0.0
local laps = {}
local newLap = false
local newLapTime = 0.0


local function StartTimer()
    local timeStartS,timeStartMs = playdate.getSecondsSinceEpoch()
    timeStart = timeStartS + timeStartMs/1000
    running = true
end

local function StopTimer()
    running = false
end

local function ResetTimer()
    running = false
    timeStart = 0
    elapsedTime = 0
    laps = {}
end

local function Lap()
    local timeStartS,timeStartMs = playdate.getSecondsSinceEpoch()
    newLapTime = timeStartS + timeStartMs/1000
    newLap = true
end

local xOff,yOff = 20,20

local function Draw()
    local totalTime = elapsedTime + deltaTime
    local secondsOnly = math.floor(totalTime)

end

local function Update()
    local oldElapsed = elapsedTime

    if newLap then
        table.insert(laps, (newLapTime - timeStart))
        elapsedTime += newLapTime - timeStart
        timeStart = newLapTime
        newLap = false
        newLapTime = 0.0
    end

    if running then
        local timeStartS,timeStartMs = playdate.getSecondsSinceEpoch()
        local currentTime = timeStartS + timeStartMs/1000
        deltaTime = currentTime - timeStart 
    else
        local timeStartS,timeStartMs = playdate.getSecondsSinceEpoch()
        local currentTime = timeStartS + timeStartMs/1000
        deltaTime = currentTime - timeStart 
        elapsedTime += deltaTime
        deltaTime = 0.0
    end
    Draw()
end

local function HandleAButton()
    if running then
        Lap()
    else
        StartTimer()
    end
end

local function HandleBButton()
    if running then
        StopTimer()
    else
        ResetTime()
    end
end

local function DoNothing()
end

local function HandleCrank(change, accelChange)
end

function StopwatchScreenBuilder()
    local screen = {
        AButton = HandleAButton,
        BButton = HandleBButton,
        Down = DoNothing,
        Up = DoNothing,
        Left = DoNothing,
        Right = DoNothing,
        Crank = HandleCrank,
        DrawScreen = Draw,
        UpdateScreen = Update
    }

    return screen
end
