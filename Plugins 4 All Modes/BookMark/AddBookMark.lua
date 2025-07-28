PluginName = "‎添修书签"
PluginType = 0
PluginMode = 7
PluginRequire = "6.0.52"

--require "base"

function PrintBeat(b, mark)
    print(string.format("%s{%d,%d,%d}", mark, b.beat, b.numor, b.denom))
end

function ReadBookMark(line)
    local b, t
    for b1, b2, b3, content in string.gmatch(line, "Beat:{(%d+),(%d+),(%d+)},Content:([^;]+);") do
        b = Editor:MakeBeat(b1, b2, b3)
        t = { b, content }
    end
    return t
end

-- return b1>b2
function BeatLarger(b1, b2)
    PrintBeat(b1, "BeatLarger_b1:")
    PrintBeat(b2, "BeatLarger_b2:")
    if b1.beat > b2.beat then
        return true
    elseif b1.beat == b2.beat then
        return (b1.numor * b2.denom) > (b1.denom * b2.numor)
    else
        return false
    end
end

function SortBookMarks()
    local beat_list = {}
    local cnt = tonumber(Editor:ReadData("bookmark", "count"))
    -- 将书签转为表，便于排序
    for i = 0, cnt - 1 do
        local line = Editor:ReadData("bookmark", tostring(i))
        local bookmark = ReadBookMark(line)
        table.insert(beat_list, bookmark)
    end
    -- 开始排序
    local swapped
    for t = 1, cnt do
        swapped = false
        for i = 1, cnt - 1 do
            local temp
            if BeatLarger(beat_list[i][1], beat_list[i + 1][1]) then
                swapped = true
                temp = beat_list[i + 1]
                beat_list[i + 1] = beat_list[i]
                beat_list[i] = temp
            end
        end
        if not swapped then
            break
        end
    end
    -- 将书签写回
    for i = 0, cnt - 1 do
        Editor:WriteData("bookmark", tostring(i), FormatBookMark(beat_list[i + 1][1], beat_list[i + 1][2]))
    end
end

function Beat2ID(b)
    local b_text = tostring(b.beat) .. tostring(b.numor) .. tostring(b.denom)
    return b_text
end

-- 将存在的书签写入文件
function WriteBookMarks()
    local cnt = tonumber(Editor:ReadData("bookmark", "count"))
    local content = ""
    for i = 0, cnt - 1 do
        content = content .. Editor:ReadData("bookmark", tostring(i)) .. "\n"
    end
    Editor:WriteFile("BookMark.txt", content)
end

function FormatBookMark(beat, content)
    return string.format("Beat:{%d,%d,%d},Content:%s;", beat.beat, beat.numor, beat.denom, content)
end

function ProcessMarkText(content, text_mod)
    local contLeng = utf8.len(content)
    text_mod.Text=content
    if contLeng <= 10 then
        text_mod.X = 87.5
    elseif (contLeng > 10) and (contLeng <= 20) then
        text_mod.X = 87.5 - (contLeng - 10) * 1.75
    else
        text_mod.X = 70
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
        text_mod.Text = finaltext
    end
end

function DrawBookMark(beat, content, bid)
    local line = Editor:AddSprite("bookmark_line:" .. bid, "effline.png")
    local text = Editor:AddText("bookmark_content:" .. bid, content)
    line.Beat = beat
    text.Beat = beat
    line.X = 87.5
    ProcessMarkText(content, text)
    line.Width = 25
    line.Height = 30
    line:SetColor(81, 133, 255)
    text:SetColor(81, 133, 255)
end

function CheckHaveMark(beat)
    if FIRST_USE then
        return false, nil
    end
    local cnt = tonumber(Editor:ReadData("bookmark", "count"))
    local beat_text = string.format("{%d,%d,%d}", beat.beat, beat.numor, beat.denom)
    local line, result
    for i = 0, cnt - 1 do
        line = Editor:ReadData("bookmark", tostring(i))
        result = string.find(line, beat_text)
        if result ~= nil then
            return true, tostring(i)
        end
    end
    return false, nil
end

function Main(userinput)
    local cnt = 0
    if not FIRST_USE then
        cnt = tonumber(Editor:ReadData("bookmark", "count")) or 0
    end

    local tip = "书签已添加"
    local name = userinput
    local curBeat = Editor:GetCurrentBeat()

    local haveMark, confilctID = CheckHaveMark(curBeat)
    if haveMark then
        tip = "已修改此处书签"
        Editor:WriteData("bookmark", confilctID, FormatBookMark(curBeat, name))
        local text = Editor:FindModule("bookmark_content:" .. Beat2ID(curBeat))
        ProcessMarkText(name,text)
        goto writeFile
    end

    --print("namekind:",name,type(name))
    DrawBookMark(curBeat, name, Beat2ID(curBeat))
    Editor:WriteData("bookmark", cnt, FormatBookMark(curBeat, name))
    cnt = cnt + 1
    Editor:WriteData("bookmark", "count", tostring(cnt))
    SortBookMarks()

    ::writeFile::
    WriteBookMarks()
    Editor:ShowMessage(tip)
end

function Run()
    --print(base.con)
    print(utf8.offset("a好好好", 3))
    FIRST_USE = false
    local content_file = Editor:ReadFile("BookMark.txt")

    if (content_file == nil) or (content_file == "") then
        Editor:WriteData("bookmark", "enabled", "true")
        FIRST_USE = true
        goto entry
    end

    if Editor:ReadData("bookmark", "enabled") ~= "true" then
        Editor:ShowMessage("请先读取书签")
        return
    end
    ::entry::
    Editor:GetUserInput("请输入书签名称", "Untitled", Main)
end
