--Plugin By Creeper_001
PluginName="Bezier Slide"
PluginType=0
PluginMode=7
PluginRequire="6.0.0"

Slide=2048

--将浮点数转为整数，以四舍五入的方式
function float2int(n)
    local _,d=math.modf(n)
    if d>=0.5 then
        return math.ceil(n)
    else
        return math.floor(n)
    end
end

--Beat除法运算
function BeatDivision(beat,div)
    local a=beat.beat
    local b=beat.numor
    local c=beat.denom
    return Editor:MakeBeat(math.ceil((a*c+b)//(c*div)),math.ceil((a*c+b)%(c*div)),math.ceil(c*div))

end

--组合数计算
function C(m,n)
    return factorial(m)/(factorial(n)*factorial(m-n))
end

--阶乘计算
function factorial(n)
    if n==0 then
        return 1
    else
        return n*factorial(n-1)
    end
end

--将Beat转化为浮点数
function Beat2Float(beat)
    return beat.beat+beat.numor/beat.denom
end

--获取被转化的条的节点，以作为贝塞尔曲线的控制点&起终点
function GetPoints(slide)
    local Pointslist={}
    local StartBeat=Beat2Float(Editor:GetNoteBeat(slide,true))
    local StartX=Editor:GetNoteX(slide)
    table.insert(Pointslist,{StartBeat,StartX})
    for i=0,Editor:GetNoteSlideBodyCount(slide)-1 do
        local SegX=Editor:GetNoteSlideBodyX(slide,i)+StartX
        local SegBeat=Beat2Float(Editor:BeatAdd(Editor:GetNoteSlideBodyBeat(slide,i),Editor:GetNoteBeat(slide,true)))
        table.insert(Pointslist,{SegBeat,SegX})
    end
    return Pointslist
end

--贝塞尔曲线计算
function Bezier(pointlist,t)
    local sumBeat=0
    local sumX=0
    for i=0,#pointlist-1 do
        sumBeat=sumBeat+C(#pointlist-1,i) * pointlist[i+1][1] * (1-t)^(#pointlist-1 -i) * t^i
        sumX=sumX+C(#pointlist-1,i) * pointlist[i+1][2] * (1-t)^(#pointlist-1 -i) * t^i
    end
    return sumBeat,sumX
end

--获取指定beat对应的t值
function GetT(pointlist,tarBeat)
    local t1=0
    local t2=1
    local tmid=0
    local t1Beat,tmidBeat=0,0
    while math.abs(t2-t1)>0.00001 do
        tmid=(t1+t2)/2
        t1Beat,_=Bezier(pointlist,t1)-tarBeat
        tmidBeat,_=Bezier(pointlist,tmid)-tarBeat
        if tmidBeat==tarBeat then
            return tmid
        end
        if tmidBeat*t1Beat>0 then
            t1=tmid
        else
            t2=tmid
        end
    end
    return t1
end

--[[放置长条
    步骤：清空节点→计算指定beat对应的t值→计算t对应的x值→放置节点]]--
function PlaceSlide(steps,slide,pointlist)
    --检测步长是否合理
    if string.match(steps,'[^0-9]') then
            Editor:ShowMessage('不合理的步长\nIllegal Steps')
            Editor:GetUserInput("4",PlaceSlide)
            return
    elseif tonumber(steps)<=0 then
            Editor:ShowMessage('不合理的步长\nIllegal Steps')
            Editor:GetUserInput("4",PlaceSlide)
            return
    end
    slide=slide or TarNote
    pointlist=pointlist or Pointlist
    local slideendB=Editor:GetNoteBeat(slide,false)
    local slidestartB=Editor:GetNoteBeat(slide,true)
    local slidestart=pointlist[1][1]
    local slideend=pointlist[#pointlist][1]
    local addition=BeatDivision(Editor:BeatMinus(slideendB,slidestartB),tonumber(steps))
    local startx=pointlist[1][2]
    local segbeat=Editor:MakeBeat(0,0,1)
    Editor:StartBatch()
    Editor:DeleteNoteSlideBody(slide)
    for i=0,tonumber(steps)-1 do
        local segbeat_f=slidestart+(slideend-slidestart)*(i+1)/(tonumber(steps))
        segbeat=Editor:BeatAdd(segbeat,addition)
        print('t: '..GetT(pointlist,segbeat_f))
        local _,segx=Bezier(pointlist,GetT(pointlist,segbeat_f))
        segx=segx-startx
        Editor:AddNoteSlideBody(slide,segbeat)
        Editor:SetNoteSlideBodyX(slide,i,float2int(segx))
    end
    Editor:FinishBatch()
    Editor:ShowMessage("Slide已生成\nSlide Generated")
end

function Run()
    if Editor:GetSelectNotes().Length==1 and Editor:GetNoteType(Editor:GetSelectNotes()[0])==2048 then
        TarNote=Editor:GetSelectNotes()[0]
    else
        Editor:ShowMessage("请选择一个Slide Note\nPlease Choose a Slide Note")
        return
    end
    Pointlist=GetPoints(TarNote)
    Editor:ShowMessage("输入步长\nInput Steps")
    Editor:GetUserInput("4",PlaceSlide)
end