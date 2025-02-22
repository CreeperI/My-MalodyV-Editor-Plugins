
--Plugin By Creeper_001
PluginName = "等距变速"
PluginMode = 7
PluginType = 2
PluginIcon = "NxlookingSV.png"
PluginRequire = "6.0.62"

--function printbeat(b, text)
--    print(text .. " beat:{" .. b.beat, b.numor, b.denom .. "}")
--end

function decimal_place(num)
    num = tostring(num)
    local pos_pot = string.find(num, "%.")
    if pos_pot == nil then
        return 0
    else
        local length = #num - pos_pot
        return length
    end
end

function gcd(a, b)
    print("inputed in gcd:", a, b)
    a = math.ceil(a)
    b = math.ceil(b)
    while b ~= 0 do
        local r = a % b
        a = b
        b = r
        print("cur progress(a,b,r):", a, b, r)
    end
    return a
end

function GetSV(userinput)
    SV1, SV2, SVBase = string.match(userinput, "([%d%.]+),([%d%.]+),([%d%.]+)")
    if SVBase == nil then SVBase = 1 end
    SV1, SV2, SVBase = tonumber(SV1), tonumber(SV2), tonumber(SVBase)
    Editor:GetUserInput("按A/B的分数格式或整数来输入等效距离", "1", Main)
end

function Main(userinput)
    if string.find(userinput, "/") == nil then userinput = userinput .. "/1" end
    B1, B2 = string.match(userinput, "(%d+)/(%d+)")
    local resultU = SVBase * B1 * (1 - SV2)
    local resultD = B2 * (SV1 - SV2) --计算距离
    --print("S1: ", resultU, resultD)
    if decimal_place(resultU) > decimal_place(resultD) then
        resultU = resultU * (10 ^ decimal_place(resultU))
        resultD = resultD * (10 ^ decimal_place(resultU))
    else
        resultU = resultU * (10 ^ decimal_place(resultD))
        resultD = resultD * (10 ^ decimal_place(resultD))
    end --使分子分母均变成整数
    --print("S2: ", resultU, resultD)
    local gcd_of_A_and_B = gcd(resultU, resultD)
    resultU = math.ceil(resultU / gcd_of_A_and_B)
    resultD = math.ceil(resultD / gcd_of_A_and_B) --计算最大公约数并对beat结果进行约分
    --print("S3: ", resultU, resultD)
    local resultbeat = Editor:MakeBeat(resultU // resultD, resultU % resultD, resultD)
    --printbeat(resultbeat, "result")
    Editor:DeleteEffect(StartBeat, "sv")
    Editor:DeleteEffect(Editor:BeatAdd(StartBeat, resultbeat), "sv")
    Editor:AddEffect(StartBeat, "sv", SV1)
    Editor:AddEffect(Editor:BeatAdd(StartBeat, resultbeat), "sv", SV2) --删除生成位置原有的SV并替换成新添加的SV
    Editor:ShowMessage("SV组已生成")
end

function OnClick()
    StartBeat = Editor:GetClickBeat()
    Editor:GetUserInput("按a,b,c格式依次输入第一，二个变速以及基础变速", "a,b,c", GetSV)
end

function OnActive()
    Editor:ShowMessage("点击任意一个节拍线处来生成SV\n注意：若要生成SV的地方已有SV，原有SV将会被替换")
end
