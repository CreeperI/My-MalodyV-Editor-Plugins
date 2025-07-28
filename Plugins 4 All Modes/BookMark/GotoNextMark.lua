--Plugin By Creeper_001
PluginName = "‎下个书签"
PluginType = 0
PluginMode = 7
PluginRequire = "6.0.52"

function ReadMarkBeat(line)
    for b1,b2,b3 in string.gmatch(line,"Beat:{(%d+),(%d+),(%d+)}") do
        local b=Editor:MakeBeat(b1,b2,b3)
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
    local cnt=Editor:ReadData("bookmark","count")
    local nextBeat,nextLine
    for i=0,cnt-1 do
        nextLine=Editor:ReadData("bookmark",tostring(i))
        nextBeat=ReadMarkBeat(nextLine)
        if BeatLarger(nextBeat,curBeat) then
            Editor:SeekTo(nextBeat)
            return
        end
    end
    nextLine=Editor:ReadData("bookmark",tostring(0))
    nextBeat=ReadMarkBeat(nextLine)
    Editor:SeekTo(nextBeat)
end
