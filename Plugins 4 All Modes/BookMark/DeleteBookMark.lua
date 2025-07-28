--Plugin By Creeper_001
PluginName = "‎删除书签"
PluginType = 0
PluginMode = 7
PluginRequire = "6.0.52"

function WriteBookMarks()
    local cnt = tonumber(Editor:ReadData("bookmark", "count"))
    local content = ""
    for i = 0, cnt - 1 do
        content = content .. Editor:ReadData("bookmark", tostring(i)) .. "\n"
    end
    Editor:WriteFile("BookMark.txt", content)
end

function CheckHaveMark(beat)
    local cnt=tonumber(Editor:ReadData("bookmark","count"))
    local beat_text=string.format("{%d,%d,%d}",beat.beat,beat.numor,beat.denom)
    local line,result
    for i=0,cnt-1 do
        line=Editor:ReadData("bookmark",tostring(i))
        result=string.find(line,beat_text)
        if result~=nil then
            return true,i
        end
    end
    return false,nil
end

function Beat2ID(b)
    local b_text = tostring(b.beat) .. tostring(b.numor) .. tostring(b.denom)
    return b_text
end

function Run()
    local cnt=tonumber(Editor:ReadData("bookmark","count"))
    local curBeat=Editor:GetCurrentBeat()
    local haveMark,ConfilctID=CheckHaveMark(curBeat)
    if not haveMark then
        Editor:ShowMessage("此处没有书签")
        return
    end

    local nextData=""
    for i=ConfilctID,cnt-2 do
        nextData=Editor:ReadData("bookmark",tostring(i+1))
        Editor:WriteData("bookmark",tostring(i),nextData)
    end
    Editor:WriteData("bookmark",tostring(cnt-1),"")
    Editor:WriteData("bookmark","count",tostring(cnt-1))
    Editor:RemoveModule("bookmark_line:"..Beat2ID(curBeat))
    Editor:RemoveModule("bookmark_content:"..Beat2ID(curBeat))
    WriteBookMarks()
    Editor:ShowMessage("书签已删除")
end
