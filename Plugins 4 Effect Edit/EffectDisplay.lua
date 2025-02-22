--Plugin By Creeper_001
PluginName = "Effect显示/隐藏"
PluginMode = 7
PluginType = 0
PluginRequire = "6.0.72"

function Beat2Float(beat)
    return '{' .. beat.beat .. ',' .. beat.numor .. ', ' .. beat.denom .. '}'
end

function Scrap(v, min, max)
    if v <= min then
        return min
    elseif v >= max then
        return max
    else
        return v
    end
end

function ShowEffect1(beat, type, value, id)
    local mod_text, mod_line
    mod_text = Editor:AddText('eff' .. id, type .. ': ' .. value)
    mod_line = Editor:AddSprite('line' .. id, 'effline.png')
    mod_text.Beat = beat
    mod_text.Width = 10
    mod_text.Height = 30

    mod_line.Beat = beat
    mod_line.Height = 40
    if type == "sv" or type == "scroll" or type == "hs" then
        mod_text.X = 90
        mod_text:SetColor(0, 200, 0)
        mod_line.Width = Scrap(5 * math.abs(value), 2, 100)
        mod_line.X = 100 - (mod_line.Width / 2)
        mod_line:SetColor(0, 200, 0)
    elseif type == "jump"
    then
        mod_text.X = 10
        mod_text:SetColor(200, 175, 0)
        mod_line.Width = Scrap(5 * math.abs(value) * 0.025, 2, 100)
        mod_line.X = mod_line.Width / 2
        mod_line:SetColor(200, 175, 0)
    end
end

function ShowEffect()
    local count = Editor:GetEffectCount()
    local effect, effbeat, efftype, effvalue
    for i = 0, count - 1 do
        effect = Editor:GetEffectAt(i)
        effbeat = effect.beat
        efftype = effect.type
        effvalue = effect.value
        ShowEffect1(effbeat, efftype, effvalue, i)
    end
    Editor:WriteData("display", "EffectDisPlay", "true")
end

function HideEffect()
    for i = 0, Editor:GetEffectCount() - 1 do
        Editor:RemoveModule("eff" .. i)
        Editor:RemoveModule("line" .. i)
        Editor:WriteData("display", "EffectDisPlay", "false")
    end
end

function Run()
    if Editor:ReadData("display", "EffectDisPlay") == nil or Editor:ReadData("display", "EffectDisPlay") == "false" or Editor:ReadData("display", "EffectDisPlay") == '' then
        ShowEffect()
    else
        HideEffect()
    end
end
