--Plugin By Creeper_001
PluginName = 'Slide拆分'
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
            print("situation1_output", Beat2String(seg_table[mid_index][2]), seg_table[mid_index][1])
            return { mid_index }
        elseif Less_Beat(seg_table[mid_index][2], cur_beat, false) then
            l_index = mid_index + 1
        else
            r_index = mid_index
        end
    end
    return { l_index - 1, l_index }
end

function Slide_Clip(seg_table, index_table, slide, cur_beat)
    local width = Editor:GetNoteWidth(slide)
    if #index_table == 1 then --当前所处beat在某个节点上
        local clip_index = index_table[1]
        Editor:StartBatch()
        local bottomslide = Editor:AddNote(2048)
        Editor:SetNoteBeat(bottomslide, seg_table[1][2], true)
        Editor:SetNoteX(bottomslide, seg_table[1][4])
        Editor:SetNoteWidth(bottomslide, width)
        for seg_id = 2, clip_index do
            Editor:AddNoteSlideBody(bottomslide, seg_table[seg_id][3])
            Editor:SetNoteSlideBodyX(bottomslide, seg_id - 2, seg_table[seg_id][5])
        end
        local topslide = Editor:AddNote(2048)
        local topslide_x = seg_table[clip_index][4]
        local topslide_beat = seg_table[clip_index][2]
        Editor:SetNoteBeat(topslide, topslide_beat, true)
        Editor:SetNoteX(topslide, topslide_x)
        Editor:SetNoteWidth(topslide, width)
        for seg_id = clip_index + 1, #seg_table - 1 do
            Editor:AddNoteSlideBody(topslide, Editor:BeatMinus(seg_table[seg_id][2], topslide_beat))
            Editor:SetNoteSlideBodyX(topslide, seg_id - clip_index - 1, seg_table[seg_id][4] - topslide_x)
        end
        Editor:DeleteNote(slide)
        Editor:FinishBatch()
    else --当前所处beat在两个节点之间，处理方法是手动插入截取点，将问题转化为第一种情况
        local l_index, r_index = index_table[1], index_table[2]
        local beat1, beat2 = Editor:BeatMinus(cur_beat, seg_table[l_index][2]),
            Editor:BeatMinus(seg_table[r_index][2], seg_table[l_index][2])
        local percentage = BeatDivision(beat1, beat2) --计算当前beat在两个节点之间的百分比
        local clippoint_seg =
        {
            nil,
            cur_beat,
            Editor:BeatMinus(cur_beat, seg_table[1][2]),
            math.floor(seg_table[l_index][4] + (seg_table[r_index][4] - seg_table[l_index][4]) * percentage),
            math.floor((seg_table[l_index][4] + (seg_table[r_index][4] - seg_table[l_index][4]) * percentage) -
                seg_table[1][4])
        }
        --print("percentage",percentage)
        table.insert(seg_table, l_index + 1, clippoint_seg)
        local clip_index = l_index + 1
        Editor:StartBatch()
        local bottomslide = Editor:AddNote(2048)
        Editor:SetNoteBeat(bottomslide, seg_table[1][2], true)
        Editor:SetNoteX(bottomslide, seg_table[1][4])
        Editor:SetNoteWidth(bottomslide, width)
        for seg_id = 2, clip_index do
            Editor:AddNoteSlideBody(bottomslide, seg_table[seg_id][3])
            Editor:SetNoteSlideBodyX(bottomslide, seg_id - 2, seg_table[seg_id][5])
        end
        local topslide = Editor:AddNote(2048)
        local topslide_x = seg_table[clip_index][4]
        local topslide_beat = seg_table[clip_index][2]
        Editor:SetNoteBeat(topslide, topslide_beat, true)
        Editor:SetNoteX(topslide, topslide_x)
        Editor:SetNoteWidth(topslide, width)
        for seg_id = clip_index + 1, #seg_table - 1 do
            Editor:AddNoteSlideBody(topslide, Editor:BeatMinus(seg_table[seg_id][2], topslide_beat))
            Editor:SetNoteSlideBodyX(topslide, seg_id - clip_index - 1, seg_table[seg_id][4] - topslide_x)
        end
        Editor:DeleteNote(slide)
        Editor:FinishBatch()
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
    Slide_Clip(slide_seg_table, index_table, note, cur_beat)
    Editor:ShowMessage("Slide裁剪完成")
end
