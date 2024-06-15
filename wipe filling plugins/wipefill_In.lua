--Plugin Made By Creeper_001

PluginName='wipe_In'
PluginMode=7
PluginType=0
PluginRequire="5.2.6"

wipe=1024
tap=1

function min(a,b)
	if a<b then
		return a
	else
		return b
	end
end

function easing(x,steps,i)
  local eased_x=0
  local xx=i/steps
  local percentage=xx*xx
  --local percentage=xx^3
  local eased_x=math.floor(percentage*x)
  return eased_x
end

function beattimes()
	local up=(TotalBeat.beat*TotalBeat.denom+TotalBeat.numor)*Beat_unit.denom
	local down=(Beat_unit.beat*Beat_unit.denom+Beat_unit.numor)*TotalBeat.denom
	local times=up/down
	return times
end
--以下进入正题

function Run()
	Editor:StartBatch()--开始
	Notes=Editor:GetSelectNotes()
	if Notes.Length==2 then
	  Step=Editor:GetCurrentDivide()

	  if Editor:GetNoteTime(Notes[1],true)>Editor:GetNoteTime(Notes[0],true) then
	  	StartBeat=Editor:GetNoteBeat(Notes[0],true)
	  	EndBeat=Editor:GetNoteBeat(Notes[1],true)
	  	StartX=Editor:GetNoteX(Notes[0])
	  	EndX=Editor:GetNoteX(Notes[1])
	  	StartWidth=Editor:GetNoteWidth(Notes[0])
	  	EndWidth=Editor:GetNoteWidth(Notes[1])
	  else
	  	StartBeat=Editor:GetNoteBeat(Notes[1],true)
	  	EndBeat=Editor:GetNoteBeat(Notes[0],true)
	  	StartX=Editor:GetNoteX(Notes[1])
	  	EndX=Editor:GetNoteX(Notes[0])
	  	StartWidth=Editor:GetNoteWidth(Notes[1])
	  	EndWidth=Editor:GetNoteWidth(Notes[0])
	  end
	  TotalBeat=Editor:BeatMinus(StartBeat,EndBeat)
	  Moved=EndX-StartX
	  WidthChanged=EndWidth-StartWidth
	  Beat_unit=Editor:MakeBeat(0,1,Step)
	  beat_times=math.abs(beattimes())
	  --创建note
	  local nid=0
	  for i=1,beat_times-1 do
	  	nid=Editor:AddNote(wipe)
	  	addtion=Editor:MakeBeat(i//Step,i%Step,Step)
	  	wipe_beat=Editor:BeatAdd(addtion,StartBeat)
	  	Editor:SetNoteBeat(nid,wipe_beat,true)
	  	Editor:SetNoteX(nid,StartX+easing(Moved,beat_times,i))
	  	Editor:SetNoteWidth(nid,StartWidth+easing(WidthChanged,beat_times,i))
	  end
	else
		Editor:ShowMessage("只能选择2个note\nYou can only choose 2 notes.")
	end
	Editor:FinishBatch()
end