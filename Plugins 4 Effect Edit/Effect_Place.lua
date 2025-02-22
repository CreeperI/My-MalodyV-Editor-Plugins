--Plugin By Creeper_001
PluginName = "Effect放置"
PluginMode = 7
PluginType = 2
PluginRequire = "6.0.72"
PluginIcon = "plugin.png"

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

function RefreshEffDisplay()
    local status = Editor:ReadData("display", "EffectDisPlay")

    if status == "false" or status == nil or status == '' then
        return
    else
        HideEffect()
        ShowEffect()
    end
end

function Place(value)
    value = tonumber(value)
    Editor:AddEffect(Clickbeat, Efftype, value)
    RefreshEffDisplay()
end

function OnClick()
    Clickbeat = Editor:GetClickBeat()
    Efftype = Editor:ReadData("type", "effchange")
    if Efftype == nil or Efftype == '' then
        Editor:ShowMessage("未获取到effect类型，请输入类型后再试")
        return
    end
    Editor:GetUserInput("输入" .. Efftype .. "的值", "1", Place)
end
