--Plugin Made By Creeper_001
PluginName = "Note横向拉伸"
PluginMode = 7
PluginType = 0
PluginRequire = "6.0.0"

Slide = 2048

function debud()
    str = string.format("%q,%q,%f", ValueList[1], ValueList[2], ValueList[3])
    Editor:ShowMessage(str)
end

function GetMaxandMinValue(notelist)
    local max = 0
    local min = 32767
    for note = 0, notelist.Length - 1 do
        local X = Editor:GetNoteX(notelist[note])
        local ntype = Editor:GetNoteType(notelist[note])
        if X > max then
            max = X
        end
        if X < min then
            min = X
        end
        if ntype == Slide then
            local SlideBodyCount = Editor:GetNoteSlideBodyCount(notelist[note])
            for slidebody = 0, SlideBodyCount - 1 do
                X = Editor:GetNoteSlideBodyX(notelist[note], slidebody) + Editor:GetNoteX(notelist[note])
                if X > max then
                    max = X
                end
                if X < min then
                    min = X
                end
            end
        end
    end
    return { min, max, (min + max) / 2 }
end

function GetAlign(userinput)
    Align = userinput
    Editor:GetUserInput("输入伸缩倍数", Stretch)
end

function Stretch(userinput)
    Scale = tonumber(userinput)
    Editor:StartBatch()
    for note = 0, notes.Length - 1 do
        local curnote = notes[note]
        local curnotetype = Editor:GetNoteType(curnote)
        local RawX = Editor:GetNoteX(curnote)
        if Align == "0" then
            local X = ValueList[3] + (RawX - ValueList[3]) * Scale
            Editor:SetNoteX(curnote, math.ceil(X))
            if curnotetype == Slide then
                local slidebodycount = Editor:GetNoteSlideBodyCount(curnote)
                for slidebody = 0, slidebodycount - 1 do
                    local BodyRawX = Editor:GetNoteSlideBodyX(curnote, slidebody) + RawX
                    local BodyX = ValueList[3] + (BodyRawX - ValueList[3]) * Scale
                    Editor:SetNoteSlideBodyX(curnote, slidebody, math.ceil(BodyX - X))
                end
            end
        end
        if Align == "1" then
            local X = ValueList[1] + (RawX - ValueList[1]) * Scale
            Editor:SetNoteX(curnote, math.ceil(X))
            if curnotetype == Slide then
                local slidebodycount = Editor:GetNoteSlideBodyCount(curnote)
                for slidebody = 0, slidebodycount - 1 do
                    local BodyRawX = Editor:GetNoteSlideBodyX(curnote, slidebody) + RawX
                    local BodyX = ValueList[1] + (BodyRawX - ValueList[1]) * Scale
                    Editor:SetNoteSlideBodyX(curnote, slidebody, math.ceil(BodyX - X))
                end
            end
        end
        if Align == "2" then
            local X = ValueList[2] + (RawX - ValueList[2]) * Scale
            Editor:SetNoteX(curnote, math.ceil(X))
            if curnotetype == Slide then
                local slidebodycount = Editor:GetNoteSlideBodyCount(curnote)
                for slidebody = 0, slidebodycount - 1 do
                    local BodyRawX = Editor:GetNoteSlideBodyX(curnote, slidebody) + RawX
                    local BodyX = ValueList[2] + (BodyRawX - ValueList[2]) * Scale
                    Editor:SetNoteSlideBodyX(curnote, slidebody, math.ceil(BodyX - X))
                end
            end
        end
    end
    Editor:FinishBatch()
end

function Run()
    notes = Editor:GetSelectNotes()
    ValueList = GetMaxandMinValue(notes)
    Editor:GetUserInput("输入缩放中心(0/1/2)", GetAlign)
    Editor:ShowMessage("0代表中心，1表示左对齐，2表示右对齐")
end
