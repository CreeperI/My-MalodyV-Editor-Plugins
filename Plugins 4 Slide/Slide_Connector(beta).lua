--Plugin Made By Creeper_001
PluginName = 'Slide Connector'
PluginMode = 7
PluginType = 0
PluginRequire = "5.2.6"

--Caution: The undo function cannot be finished because of some unknown problem.
--And the plugin may be remaked in the future.
f = Editor
beat = { beat = 0, numor = 1, denom = 4 }

function notecomparer(n1, n2, type, returnlarge)
    local n1S = f:GetNoteTime(n1, true)
    local n2S = f:GetNoteTime(n2, true)
    local n1E = f:GetNoteTime(n1, false)
    if type == 0 then
        if n1E == n2S then
            return nil
        elseif n1E > n2S then
            if returnlarge == true then
                return n1
            else
                return n2
            end
        elseif n1E < n2S then
            if returnlarge == true then
                return n2
            else
                return n1
            end
        end
    elseif type == 1 then
        if n1S == n2S then
            return nil
        elseif n1S > n2S then
            if returnlarge == true then
                return n1
            else
                return n2
            end
        elseif n1S < n2S then
            if returnlarge == true then
                return n2
            else
                return n1
            end
        end
    end
end

function Run()
    notes = f:GetSelectNotes()
    --f:ShowMessage(string.format("%d,%d", notes[0], notes[1]))
    if notes.Length == 2 then
        Baseslide = notecomparer(notes[0], notes[1], 1, false)
        AppendSlide = notecomparer(notes[0], notes[1], 1, true)
        if f:GetNoteTime(AppendSlide, true) >= f:GetNoteTime(Baseslide, false) and Baseslide ~= nil then --判断slide是否有重叠
            BaseslideBeat = f:GetNoteBeat(Baseslide, true)
            BaseslideX = f:GetNoteX(Baseslide)
            AppendSlideBeat = f:GetNoteBeat(AppendSlide, true)
            AppendSlideX = f:GetNoteX(AppendSlide)
            if f:GetNoteTime(AppendSlide, true) ~= f:GetNoteTime(Baseslide, false) then
                AppendBeat = f:BeatMinus(AppendSlideBeat, BaseslideBeat)
                AppendX = AppendSlideX - BaseslideX
                f:AddNoteSlideBody(Baseslide, AppendBeat)
                BaseSlideCount = f:GetNoteSlideBodyCount(Baseslide)
                f:SetNoteSlideBodyX(Baseslide, BaseSlideCount - 1, AppendX)
            end
            for i = 0, f:GetNoteSlideBodyCount(AppendSlide) - 1 do
                CenterBeat = f:BeatAdd(AppendSlideBeat, f:GetNoteSlideBodyBeat(AppendSlide, i))
                AppendBeat = f:BeatMinus(CenterBeat, BaseslideBeat)
                CenterX = f:GetNoteSlideBodyX(AppendSlide, i) + AppendSlideX
                AppendX = CenterX - BaseslideX
                f:AddNoteSlideBody(Baseslide, AppendBeat)
                BaseSlideCount = f:GetNoteSlideBodyCount(Baseslide)
                f:SetNoteSlideBodyX(Baseslide, BaseSlideCount - 1, AppendX)
            end
            f:DeleteNote(AppendSlide)
        else
            f:ShowMessage('两个slide应【头尾相接】或【两个条时间完全错开】')
        end
    else
        f:ShowMessage('应选择两个slide')
    end
end
