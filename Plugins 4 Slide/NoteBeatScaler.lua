--Plugin By Creeper_001
PluginName = "Note纵向拉伸"
PluginMode = 7
PluginType = 0
PluginRequire = "6.0.0"

Slide = 2048

function Printbeat(beat, sign)
    print(sign .. string.format("{%d,%d,%d}", beat.beat, beat.numor, beat.denom))
end

function Calculate_scaled_beat(beat)
    local up = ScaleA * (beat.beat * beat.denom + beat.numor)
    local down = ScaleB * beat.denom
    return Editor:MakeBeat(up // down, up % down, down)
end

function Beat2float(beat)
    return (beat.beat * beat.denom + beat.numor) / beat.denom
end

function GetBeatValueMaxorMin()
    local max = -math.huge
    local min = math.huge
    local maxbeat = nil
    local minbeat = nil
    for n = 0, Notes.Length - 1 do
        local nbeat = Editor:GetNoteBeat(Notes[n], true)
        local nbeatf = Beat2float(nbeat)
        local ntype = Editor:GetNoteType(Notes[n])
        if nbeatf > max then
            max = nbeatf
            maxbeat = nbeat
        end
        if nbeatf < min then
            min = nbeatf
            minbeat = nbeat
        end
       if ntype == Slide then
            local nendbeat=Editor:GetNoteBeat(Notes[n],false)
            local nendbeatf=Beat2float(nendbeat)
            if nendbeatf > max then
                max = nendbeatf
                maxbeat = nendbeat
            end
            if nendbeatf < min then
                min = nendbeatf
                minbeat = nendbeat
            end
        end
    end
    return { maxbeat, minbeat }
end

function GetAlign(userinput)
    Align = userinput
    Editor:GetUserInput("缩放倍数", Stretch)
    Editor:ShowMessage("请输入形如a/b的分数！\n例如要缩为0.5倍原长请输入1/2而非0.5；a,b要均为整数")
end

function Stretch(userinput)
    if string.find(userinput, "/") == nil then userinput = userinput .. "/1" end
    ScaleA, ScaleB = string.match(userinput, "(%d+)/(%d+)") --A指分子，B指分母
    local slideinfo = {}
    Editor:StartBatch()
    if Align == "0" then
        for i = 0, Notes.Length - 1 do
            local curnote = Notes[i]
            local curnotetype = Editor:GetNoteType(curnote)
            local raw_notebeat = Editor:GetNoteBeat(curnote, true)
            local beat_difference = Editor:BeatMinus(raw_notebeat, Valuelist[2])
            local scaled_differnce = Calculate_scaled_beat(beat_difference)
            local scaled_notebeat = Editor:BeatAdd(scaled_differnce, Valuelist[2])
            Editor:SetNoteBeat(curnote, scaled_notebeat, true)
            if curnotetype == Slide then
                slideinfo = {}
                local bodycount = Editor:GetNoteSlideBodyCount(curnote)
                for j = 0, bodycount - 1 do
                    local raw_bodybeat = Editor:BeatAdd(Editor:GetNoteSlideBodyBeat(curnote, j), raw_notebeat)
                    local bodybeat_difference = Editor:BeatMinus(raw_bodybeat, Valuelist[2])
                    local scaled_body_difference = Calculate_scaled_beat(bodybeat_difference)
                    local scaled_bodybeat = Editor:BeatAdd(Valuelist[2], scaled_body_difference)
                    local scaled_bodybeat = Editor:BeatMinus(scaled_bodybeat, scaled_notebeat)
                    local bodyX = Editor:GetNoteSlideBodyX(curnote, j)
                    table.insert(slideinfo, { scaled_bodybeat, bodyX })
                end
                Editor:DeleteNoteSlideBody(curnote)
                for k, bodyinfo in ipairs(slideinfo) do
                    Editor:AddNoteSlideBody(curnote, bodyinfo[1])
                    Editor:SetNoteSlideBodyX(curnote, k - 1, bodyinfo[2])
                end
            end
        end
    end
    if Align == "1" then
        for i = 0, Notes.Length - 1 do
            local curnote = Notes[i]
            local curnotetype = Editor:GetNoteType(curnote)
            local raw_notebeat = Editor:GetNoteBeat(curnote, true)
            local beat_difference = Editor:BeatMinus(Valuelist[1], raw_notebeat)
            local scaled_differnce = Calculate_scaled_beat(beat_difference)
            local scaled_notebeat = Editor:BeatMinus(Valuelist[1], scaled_differnce)
            Editor:SetNoteBeat(curnote, scaled_notebeat, true)
            if curnotetype == Slide then
                slideinfo = {}
                local bodycount = Editor:GetNoteSlideBodyCount(curnote)
                for j = 0, bodycount - 1 do
                    local raw_bodybeat = Editor:BeatAdd(Editor:GetNoteSlideBodyBeat(curnote, j), raw_notebeat)
                    local bodybeat_difference = Editor:BeatMinus(Valuelist[1], raw_bodybeat)
                    local scaled_body_difference = Calculate_scaled_beat(bodybeat_difference)
                    local scaled_bodybeat = Editor:BeatMinus(Valuelist[1], scaled_body_difference)
                    local scaled_bodybeat = Editor:BeatMinus(scaled_bodybeat, scaled_notebeat)
                    Printbeat(bodybeat_difference, "Bodydiff")
                    Printbeat(scaled_body_difference, "ScaledBodydiff")
                    Printbeat(scaled_bodybeat, "Scaledbody")
                    local bodyX = Editor:GetNoteSlideBodyX(curnote, j)
                    table.insert(slideinfo, { scaled_bodybeat, bodyX })
                end
                Editor:DeleteNoteSlideBody(curnote)
                for k, bodyinfo in ipairs(slideinfo) do
                    Editor:AddNoteSlideBody(curnote, bodyinfo[1])
                    Editor:SetNoteSlideBodyX(curnote, k - 1, bodyinfo[2])
                end
            end
        end
    end
    Editor:FinishBatch()
end

function Run()
    Notes = Editor:GetSelectNotes()
    Valuelist = GetBeatValueMaxorMin()
    Editor:ShowMessage("0为以最底部note为缩放中心，1为最顶部note为缩放中心")
    Editor:GetUserInput("输入缩放中心(0/1)", GetAlign)
end
