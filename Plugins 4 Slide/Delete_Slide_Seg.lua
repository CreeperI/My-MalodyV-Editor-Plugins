--Plugin By Creeper_001
PluginName = '删除节点'
PluginMode = 7
PluginType = 0
PluginRequire = "5.2.6"
--beat结构为{beat,numor,denom}，即表示为beat,numor/denom的带分数

function Beat2Float(beat)
    return beat.beat + beat.numor / beat.denom
end

function Beat2String(beat)
    return string.format("{%d,%d,%d}", beat.beat, beat.numor, beat.denom)
end

--判断a是否大于b；a,b均为beat结构
function Larger_Beat(a, b, equal)
    if a.beat ~= b.beat then
        return a.beat > b.beat
    end
    local a_num, b_num = a.numor * b.denom, b.numor * a.denom
    if a_num ~= b_num then
        return a_num > b_num
    end
    return equal
end

--判断a是否小于b；a,b均为beat结构
function Less_Beat(a, b, equal)
    if a.beat ~= b.beat then
        return a.beat < b.beat
    end
    local a_num, b_num = a.numor * b.denom, b.numor * a.denom
    if a_num ~= b_num then
        return a_num < b_num
    end
    return equal
end

--将beat通分后比较是否相等；a,b均为beat结构
function Equal_Beat(a, b)
    return (b.denom * (a.beat * a.denom + a.numor)) == (a.denom * (b.beat * b.denom + b.numor))
end

--beat除法
function BeatDivision(a, b)
    return (b.denom * (a.beat * a.denom + a.numor)) / (a.denom * (b.beat * b.denom + b.numor))
end

--生成slide节点表
function Get_Slide_Segments_Table(slide)
    --存储方式{节点id，绝对beat，相对beat，绝对x，相对x}(注：相对是相对于原slide头)
    local slide_seg_table = {}
    local startx = Editor:GetNoteX(slide)
    local startbeat = Editor:GetNoteBeat(slide, true)
    local relative_beat, relative_x, abosolute_beat, absolute_x
    table.insert(slide_seg_table, { -1, startbeat, { beat = 0, numor = 0, denom = 1 }, startx, 0 }) --起始点信息存入
    for i = 0, Editor:GetNoteSlideBodyCount(slide) do
        relative_beat = Editor:GetNoteSlideBodyBeat(slide, i)
        relative_x = Editor:GetNoteSlideBodyX(slide, i)
        absolute_x = startx + relative_x
        abosolute_beat = Editor:BeatAdd(startbeat, relative_beat)
        table.insert(slide_seg_table, { i, abosolute_beat, relative_beat, absolute_x, relative_x })
    end
    return slide_seg_table
end

--二分法找出截取点(当前所处beat)所在位置，返回截取点在表中的位置或区间
function Find_Beat_Index(seg_table, cur_beat)
    local l_index, r_index, mid_index = 1, #seg_table - 1, nil
    while l_index < r_index do
        mid_index = (l_index + r_index) // 2
        if Equal_Beat(seg_table[mid_index][2], cur_beat) then
            return { mid_index }
        elseif Less_Beat(seg_table[mid_index][2], cur_beat, false) then
            l_index = mid_index + 1
        else
            r_index = mid_index
        end
    end
    return { l_index - 1, l_index }
end

function Seg_Delete(seg_table, index_table, slide)
    if #index_table == 1 then --当前处在某个节点上
        table.remove(seg_table, index_table[1])
        Editor:StartBatch()
        Editor:DeleteNoteSlideBody(slide)
        for seg_id = 2, #seg_table - 1 do
            Editor:AddNoteSlideBody(slide, seg_table[seg_id][3])
            Editor:SetNoteSlideBodyX(slide, seg_id - 2, seg_table[seg_id][5])
        end
        Editor:FinishBatch()
    else
        Editor:ShowMessage("此处没有节点")
    end
end

function Run()
    local selected_notes = Editor:GetSelectNotes()
    local note = selected_notes[0]
    local cur_beat = Editor:GetCurrentBeat()
    --检查选中的是不是一个slide
    if selected_notes.Length ~= 1 or Editor:GetNoteType(note) ~= 2048 then
        Editor:ShowMessage("选择的须为一个Slide")
        return
        --检查截取位置是否在slide范围内
    elseif Less_Beat(cur_beat, Editor:GetNoteBeat(note, true), false) or Larger_Beat(cur_beat, Editor:GetNoteBeat(note, false), false) then
        Editor:ShowMessage("只能在Slide中间截取")
        return
    end

    local slide_seg_table = Get_Slide_Segments_Table(note)
    local index_table = Find_Beat_Index(slide_seg_table, cur_beat)
    Seg_Delete(slide_seg_table, index_table, note)
    Editor:ShowMessage("节点已删除")
end
