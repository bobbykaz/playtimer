import 'log'

function SaveData(mode)
    local tbl = {}
    tbl["thing"] = mode
    local fileName = "example"
    Log("saving", mode,"to file",fileName)
    LogTable(tbl)
    playdate.datastore.write(tbl, fileName)
end

function SaveExists(filename)
    local tbl = playdate.datastore.read(filename)
    if tbl == nil then 
        return false
    else 
        return true
    end
end

function LoadData(filename)
    local tbl = playdate.datastore.read(filename)
    if tbl == nil then 
        return nil
    else 
        return tbl
    end
end