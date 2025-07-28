-- Plugin By Creeper_001
PluginName = "‎读取书签"
PluginType = 0
PluginMode = 7
PluginRequire = "6.0.52"

function Beat2ID(b)
    local b_text = tostring(b.beat) .. tostring(b.numor) .. tostring(b.denom)
    return b_text
end

function FormatBookMark(beat, content)
    return string.format("Beat:{%d,%d,%d},Content:%s;", beat.beat, beat.numor, beat.denom, content)
end

function DrawBookMark(beat, content, bid)
    local line = Editor:AddSprite("bookmark_line:" .. bid, "effline.png")
    local text = Editor:AddText("bookmark_content:" .. bid, content)
    line.Beat = beat
    text.Beat = beat
    line.X = 87.5
    local contLeng = utf8.len(content)
    if contLeng <= 10 then
        text.X = 87.5
    elseif (contLeng > 10) and (contLeng <= 20) then
        text.X = 87.5 - (contLeng - 10) * 1.75
    else
        text.X = 70
        local finaltext = ""
        local enterCount = contLeng // 20
        local l, r = 0, 0
        for i = 0, enterCount do
            l, r = utf8.offset(content, 1 + (20 * i)), utf8.offset(content, 20 * (1 + i) + 1)
            r = r or #content
            if r ~= #content then r = r - 1 end
            finaltext = finaltext .. string.sub(content, l, r) .. " \n"
        end
        finaltext = string.sub(finaltext, 1, #finaltext - 1)
        text.Text = finaltext
    end
    line.Width = 25
    line.Height = 30
    line:SetColor(81, 133, 255)
    text:SetColor(81, 133, 255)
end

function Run()
    local i = 0
    local content_file = Editor:ReadFile("BookMark.txt")
    if (content_file == nil) or (content_file == "") then
        Editor:ShowMessage("书签文件不存在")
        return
    end

    for b1, b2, b3, content in string.gmatch(content_file, "Beat:{(%d+),(%d+),(%d+)},Content:([^;]+);") do
        local beat = Editor:MakeBeat(b1, b2, b3)
        DrawBookMark(beat, content, Beat2ID(beat))
        Editor:WriteData("bookmark", tostring(i), FormatBookMark(beat, content))
        i = i + 1
    end
    Editor:WriteData("bookmark", "count", tostring(i))
    Editor:WriteData("bookmark", "enabled", "true")
end
