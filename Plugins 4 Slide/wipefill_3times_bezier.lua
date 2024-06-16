--Plugin Made By Creeper_001
--Bezier part was inspired by qwws
--使用提示：小tap代表控制点1；大tap表示控制点2；两个wipe代表起终点且控制点不可超过起终点的时间范围
--Caution: Use the shorter and longer tap to stands for the control point1 and 2 which are between; Use 2 wipes to appoint the start time and the end time
PluginName='wipe_Bezier'
PluginMode=7
PluginType=0
PluginRequire="5.2.6"

wipe=1024
tap=1
f=Editor

function beat2str(beat)
	return string.format('{%d,%d,%d}',beat.beat,beat.numor,beat.denom)
end

function beat2float(beat)
	return beat.beat+beat.numor/beat.denom
end

function BeatDivision(beat1,beat2)
	local up=(beat1.beat*beat1.denom+beat1.numor)*beat2.denom
	local down=(beat2.beat*beat2.denom+beat2.numor)*beat1.denom
	return up/down
end

function Get_Start_End_Info()--获取起终点信息
	if f:GetNoteTime(st_ed_p[1],true)<f:GetNoteTime(st_ed_p[2],true) then
		StartBeat=f:GetNoteBeat(st_ed_p[1],true)
		StartX=f:GetNoteX(st_ed_p[1])
		EndBeat=f:GetNoteBeat(st_ed_p[2],true)
		EndX=f:GetNoteX(st_ed_p[2])
		TotalWidth=f:GetNoteWidth(st_ed_p[1])
	elseif f:GetNoteTime(st_ed_p[1],true)>f:GetNoteTime(st_ed_p[2],true) then
		StartBeat=f:GetNoteBeat(st_ed_p[2],true)
		StartX=f:GetNoteX(st_ed_p[2])
		EndBeat=f:GetNoteBeat(st_ed_p[1],true)
		EndX=f:GetNoteX(st_ed_p[1])
		TotalWidth=f:GetNoteWidth(st_ed_p[2])
	else
		f:ShowMessage('起终点时间不能相同\nThe time of start point should be different from the end point.')
		StartBeatf=nil
		StartBeat=nil
	end
	StartBeatf=beat2float(StartBeat)
	EndBeatf=beat2float(EndBeat)
end

function GetControlInfo()
	if (beat2float(f:GetNoteBeat(control_p[1],true))>=StartBeatf and beat2float(f:GetNoteBeat(control_p[1],true))<=EndBeatf) and (beat2float(f:GetNoteBeat(control_p[2],true))>=StartBeatf and beat2float(f:GetNoteBeat(control_p[2],true))<=EndBeatf) 
	then
		if f:GetNoteWidth(control_p[1])<f:GetNoteWidth(control_p[2]) then
			p1_Beatf=beat2float(f:GetNoteBeat(control_p[1],true))
			p1_X=f:GetNoteX(control_p[1])
			p2_Beatf=beat2float(f:GetNoteBeat(control_p[2],true))
			p2_X=f:GetNoteX(control_p[2])
		elseif f:GetNoteWidth(control_p[1])>f:GetNoteWidth(control_p[2]) then
			p1_Beatf=beat2float(f:GetNoteBeat(control_p[2],true))
			p1_X=f:GetNoteX(control_p[2])
			p2_Beatf=beat2float(f:GetNoteBeat(control_p[1],true))
			p2_X=f:GetNoteX(control_p[1])
		else
			f:ShowMessage("请使tap宽度不同以区分控制点，小tap为控制点1，大tap为控制点2\nPlease use 2 taps whose width are different,\nthe shorter and longer tap stands for the control point1 and 2.")
			p1_Beat=nil
			p1_Beatf=nil
		end
	else
		f:ShowMessage("控制点不应超过起终点\nThe control points should between the start and the end points.")
		p1_Beat=nil
		p1_Beatf=nil
	end
end

function formula_Bezier(pointlist,t)
	local ps=pointlist[1]
	local p1=pointlist[2]
	local p2=pointlist[3]
	local pe=pointlist[4]
	local Bt=ps*(1-t)^3 + 3*p1*t*(1-t)^2 + 3*p2*t^2*(1-t)+pe*t^3
	return Bt
end

function Bezier(pointlistx,pointlisty,tar)
	bst=0
	bed=1
	acc=0.002
	while math.abs(bst-bed)>acc do
		fa=math.abs(formula_Bezier(pointlistx,bst)-tar)
		fb=math.abs(formula_Bezier(pointlistx,bed)-tar)
		if fa<fb then--→
			bmid=(bst+bed)/2
			bed=bed-acc
		elseif fa>fb then--→
			bmid=(bst+bed)/2
			bst=bst+acc
		elseif fa==0 then
			bmid=bst
			break
		elseif fb==0 then
			bmid=bed
			break
		elseif fa==fb then
			bmid=(bst+bed)/2
			break
		end
	end
	result=formula_Bezier(pointlisty,bmid)
	return result
end

function Run()
	control_p={}
	st_ed_p={}
	f:StartBatch()
	notes=f:GetSelectNotes()
	for i=0,notes.Length-1 do
		nt=f:GetNoteType(notes[i])
		if nt==wipe then
			table.insert(st_ed_p,notes[i])
		elseif nt==tap then
			table.insert(control_p,notes[i])
		end
	end
--分割线--
	if #st_ed_p==2 and #control_p==2 then
		Get_Start_End_Info()
		GetControlInfo()
		px={StartBeatf,p1_Beatf,p2_Beatf,EndBeatf}
		py={StartX,p1_X,p2_X,EndX}
--分割线
		div=f:GetCurrentDivide()
		Beat_Unit=f:MakeBeat(0,1,div)
		TotalBeat=f:BeatMinus(EndBeat,StartBeat)
		note_count=math.abs(BeatDivision(TotalBeat,Beat_Unit))
		nid=0
		for i=1,note_count-1 do
			nid=f:AddNote(wipe)
			addition=f:MakeBeat(i//div,i%div,div)
			wipebeat=f:BeatAdd(addition,StartBeat)
			f:SetNoteBeat(nid,wipebeat,true)
			f:SetNoteWidth(nid,TotalWidth)
			f:SetNoteX(nid,math.ceil(Bezier(px,py,beat2float(wipebeat))))
		end
		f:DeleteNote(control_p[1])
		f:DeleteNote(control_p[2])
	else
		f:ShowMessage("wipe和tap各只能选2个\nYou can only choose 2 wipes and 2 taps.")
	end
	f:FinishBatch()
end