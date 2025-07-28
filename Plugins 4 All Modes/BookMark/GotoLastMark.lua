--Plugin By Creeper_001
PluginName = "‎上个书签"
PluginType = 0
PluginMode = 7
PluginRequire = "6.0.52"

function ReadMarkBeat(line)
    for b1, b2, b3 in string.gmatch(line, "Beat:{(%d+),(%d+),(%d+)}") do
        local b = Editor:MakeBeat(b1, b2, b3)
        return b
    end
end

function BeatLarger(b1, b2)
    if b1.beat > b2.beat then
        return true
    elseif b1.beat == b2.beat then
        return (b1.numor * b2.denom) > (b1.denom * b2.numor)
    else
        return false
    end
end

function Run()
    local curBeat = Editor:GetCurrentBeat()
    local cnt = Editor:ReadData("bookmark", "count")
    local LastBeat, LastLine, lid
    for i = 0, cnt - 1 do
        lid = math.ceil(cnt - 1 - i)
        print("lid", lid)
        LastLine = Editor:ReadData("bookmark", tostring(lid))
        print("lastL", LastLine)
        LastBeat = ReadMarkBeat(LastLine)
        if BeatLarger(curBeat, LastBeat) then
            LastLine = Editor:ReadData("bookmark", tostring(i))
            Editor:SeekTo(LastBeat)
            return
        end
    end
    LastLine = Editor:ReadData("bookmark", tostring(math.ceil(cnt - 1)))
    LastBeat = ReadMarkBeat(LastLine)
    Editor:SeekTo(LastBeat)
end
