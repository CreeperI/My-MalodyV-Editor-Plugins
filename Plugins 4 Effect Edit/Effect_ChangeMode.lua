--Plugin By Creeper_001
--注意！此插件是Effect_Place(Effect放置)的附属插件！
PluginName = "更改效果类型"
PluginMode = 7
PluginType = 0
PluginRequire = "6.0.72"

AvailibleEffect = { "sv", "scroll", "jump", "hs", "sign" }

function Main(userinput)
    for _, v in pairs(AvailibleEffect) do
        if userinput == v then
            Editor:WriteData("type", "effchange", userinput)
            Editor:ShowMessage("放置类型已修改")
            return
        end
    end
    Editor:ShowMessage("该effect类型不存在")
    Editor:GetUserInput("输入effect类型(scroll/sv/hs/jump/sign)", "scroll", Main)
end

function Run()
    Editor:GetUserInput("输入effect类型(scroll/sv/hs/jump/sign)", "scroll", Main)
end
