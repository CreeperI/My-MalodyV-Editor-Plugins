--Plugin By Creeper_001
PluginName="Bezier Wipe"
PluginType=0
PluginMode=7
PluginRequire="5.0.1"

Slide=2048
Wipe=1024

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
function BeatDivision(b1,b2)
	local up=(b1.beat*b1.denom+b1.numor)*b2.denom
	local down=(b2.beat*b2.denom+b2.numor)*b1.denom
	return up/down
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

function SortPointList(pointlist)
    local temp=0
    local process=true
    while process do
        process=false
        for i=1,#pointlist-1 do
            if pointlist[i][1]>pointlist[i+1][1] then
                temp=pointlist[i]
                pointlist[i]=pointlist[i+1]
                pointlist[i+1]=temp
                process=true
            end
        end
    end
    return pointlist
end

--[[获取要被转化的wipe集合的节点，以作为贝塞尔曲线的控制点&起终点
        返回含有数个{beat,x,width,nid}格式节点信息的表]]--

function GetPoints(notes)
    local Pointslist={}
    local beat,x,w=0,0,0
    for i=0,notes.Length-1 do
        beat=Beat2Float(Editor:GetNoteBeat(notes[i],true))
        x=Editor:GetNoteX(notes[i])
        w=Editor:GetNoteWidth(notes[i])
        table.insert(Pointslist,{beat,x,w,notes[i]})
    end
    return Pointslist
end

--贝塞尔曲线计算
function Bezier(pointlist,t)
    local sumBeat=0
    local sumX=0
    local sumWidth=0
    for i=0,#pointlist-1 do
        sumBeat=sumBeat+C(#pointlist-1,i) * pointlist[i+1][1] * (1-t)^(#pointlist-1 -i) * t^i
        sumX=sumX+C(#pointlist-1,i) * pointlist[i+1][2] * (1-t)^(#pointlist-1 -i) * t^i
        sumWidth=sumWidth+C(#pointlist-1,i) * pointlist[i+1][3] * (1-t)^(#pointlist-1 -i) * t^i
    end
    return sumBeat,sumX,sumWidth
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

--获取指定beat对应的t值，将t值再反代会贝塞尔曲线求出x与width，放置wipe
function PlaceWipe(points)
    local divide=Editor:GetCurrentDivide()
    local beat_unit={beat=0,numor=1,denom=divide}
    local start_beat=Editor:GetNoteBeat(points[1][4],true)
    local end_beat=Editor:GetNoteBeat(points[#points][4],true)
    local steps=BeatDivision(Editor:BeatMinus(end_beat,start_beat),beat_unit)
    local cur_beat,cur_beat_f,wipe,cur_t=start_beat,nil,nil,nil
    local x,w=nil,nil
    Editor:StartBatch()
    for i=1,math.floor(steps)-1 do
        cur_beat=Editor:BeatAdd(cur_beat,beat_unit)
        cur_beat_f=Beat2Float(cur_beat)
        wipe=Editor:AddNote(1024)
        Editor:SetNoteBeat(wipe,cur_beat,true)
        cur_t=GetT(points,cur_beat_f)
        _,x,w=Bezier(points,cur_t)
        Editor:SetNoteX(wipe,float2int(x))
        Editor:SetNoteWidth(wipe,float2int(w))   
    end
    for i=2,#points-1 do
        Editor:DeleteNote(points[i][4])
    end
    Editor:FinishBatch()
end

function Run()
    local notes=Editor:GetSelectNotes()
    if notes.Length<=1 then 
        Editor:ShowMessage("至少选择两个Wipe")
        return 
    end
    local pointlist=GetPoints(notes)
    --print(#pointlist)
    --for i=1,#pointlist do
    --    print(string.format("before_sort_bxw:{%f,%f,%f}",pointlist[i][1],pointlist[i][2],pointlist[i][3]))
    --end
    pointlist=SortPointList(pointlist)
    --for i=1,#pointlist do
    --    print(string.format("after_sort_bxw:{%f,%f,%f}",pointlist[i][1],pointlist[i][2],pointlist[i][3]))
    --end
    PlaceWipe(pointlist)
end