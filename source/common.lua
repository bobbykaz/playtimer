function GetTimeComponents(durationMs)
    local t = math.floor(durationMs)
    local ms = t % 1000
    local seconds = (t // 1000) % 60
    local minutes = (t // 60000) % 60
    local hours = (t // 3600000) % 60
    return {
        h = hours,
        m = minutes,
        s = seconds,
        ms = ms
    }
end

function GetTimeString(tComponents, includeHours, includeMs)
    includeHours = includeHours or false
    includeMs = includeMs or true
    
    local timeString = ""
    if tComponents.h > 0 or includeHours then
        timeString = "0"..tComponents.h..":"
    end

    if tComponents.m < 10 then
        timeString = timeString.."0"..tComponents.m
    else 
        timeString = timeString..""..tComponents.m
    end

    if tComponents.s < 10 then
        timeString = timeString..":0"..tComponents.s
    else 
        timeString = timeString..":"..tComponents.s
    end

    if includeMs then
        if tComponents.ms < 10 then
            timeString = timeString..".00"..tComponents.ms
        elseif tComponents.ms < 100 then
            timeString = timeString..".0"..tComponents.ms
        else
            timeString = timeString.."."..tComponents.ms
        end
    end
    return timeString
end